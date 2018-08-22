# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  include Filterable
  include Statussable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :registerable, :confirmable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :favorites, dependent: :destroy
  has_many :email_logs, dependent: :destroy
  has_many :logs, dependent: :destroy
  has_many :todos, dependent: :destroy
  has_many :injuries, dependent: :destroy
  has_one :user_setting, dependent: :destroy
  has_and_belongs_to_many :members
  has_paper_trail

  # Add conditional validation on first_name and last_name, not executed for devise
  validates :email, presence: true

  enum role: { member: 0, club_staff: 2, admin: 1 }

  scope :asc, -> { order(last_name: :asc, first_name: :asc) }
  scope :role, ->(role) { where(role: role) }
  scope :query, ->(query) {
    where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
  }
  scope :by_email, ->(email) { where("lower(email) = ?", email.downcase) }

  after_save :update_members

  # Setter
  def name=(name)
    split = name.split(" ", 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def name
    if first_name.blank? && last_name.blank?
      email
    else
      "#{first_name} #{middle_name} #{last_name}".squish
    end
  end

  def email_with_name
    if name == email
      email
    else
      %("#{name}" <#{email}>)
    end
  end

  def teams
    Team.for_members(members).distinct
  end

  def active_teams
    Team.for_members(members).active.for_active_season.distinct
  end

  def teams_as_staff
    Team.for_members(members)
        .where.not(team_members: { role: TeamMember.roles[:player] })
        .distinct.asc
  end

  def teams_as_staff_in_season(season)
    Team.for_members(members)
        .where.not(team_members: { role: TeamMember.roles[:player] }).joins(age_group: :season)
        .where(age_groups: { season: season })
        .distinct.asc
  end

  # TODO: can't rename this to `member?` because of conflict with enum role
  def has_member?(member)
    members.where(id: member.id).size.positive?
  end

  def team_member_for?(record)
    team_id = team_id_for record
    team_id != 0 && members.joins(:team_members).where(team_members: { team_id: team_id, ended_on: nil }).size.positive?
  end

  def team_staff_for?(record)
    team_id = team_id_for record, true
    team_id != 0 && members.joins(:team_members).where(team_members: { team_id: team_id, ended_on: nil })
                           .where.not(team_members: { role: TeamMember.roles[:player] }).size.positive?
  end

  def favorite_teams
    @favorite_teams ||= Team.joins(:favorites)
                            .where(favorites: { user_id: id, favorable_type: Team.to_s })
                            .active
  end

  def favorite_age_groups
    @favorite_age_groups ||= AgeGroup.joins(:favorites)
                                     .where(favorites: { user_id: id, favorable_type: AgeGroup.to_s })
                                     .active
  end

  def favorite?(member)
    @favorite_members ||= favorites.where(favorable_type: Member.to_s).pluck(:id)
    @favorite_members.include?(member.id)
  end

  def set_new_password
    self.password = User.password
  end

  def self.password
    Password.pronounceable(8) + rand(100).to_s
  end

  def send_new_account(password)
    UserMailer.new_account_notification(self, password).deliver_now
  end

  def send_password_reset(password)
    UserMailer.password_reset(self, password).deliver_now
  end

  def prefill(member)
    self.first_name = member.first_name
    self.middle_name = member.middle_name
    self.last_name = member.last_name
    self.email = member.email
  end

  def self.find_or_create_and_invite(member)
    user = User.where(email: member.email).first_or_initialize(
      password: (generated_password = User.password),
      first_name: member.first_name, middle_name: member.middle_name, last_name: member.last_name
    )

    if user.new_record?
      user.skip_confirmation!
      user.save
      user.send_new_account(generated_password)
    end

    user
  end

  def settings
    # Auto-create user_setting
    user_setting || create_user_setting
  end

  def export_columns
    @export_columns ||= (columns = settings.export_columns).present? ? columns : Member::DEFAULT_COLUMNS
  end

  def remember_me
    true
  end

  def active_for_authentication?
    super && members.any?
  end

  def inactive_message
    "Met dit account is het op dit moment niet mogelijk om in te loggen. Je e-mailadres wordt gecontroleerd \
    via de ledenadministratie van #{Setting['club.name_short']}. Ga alsjeblieft na of je hetzelfde adres \
    gebruikt."
  end

  def toggle_include_member_comments
    include_member_comments = settings.include_member_comments
    settings.update(include_member_comments: !include_member_comments)
  end

  def active_comments_tab=(tab)
    settings.update(active_comments_tab: tab) if tab.present?
  end

  def self.deactivate_for_inactive_members
    User.active.each(&:update_members)
  end

  def self.activate_for_active_members
    User.archived.each(&:update_members)
  end

  def after_confirmation
    update_members
  end

  # Run on `after_save` because on `before_save` the email may be changed, but not yet
  # updated because of Devise's :confirmable (see `after_confirmation` above)
  def update_members
    self.members = Member.by_email(email).sportlink_active
    activate if members.any?
    deactivate if members.none?
  end

  private

    def team_id_for(record, as_team_staf = false)
      team_id = 0

      case [record.class]
      when [Team]
        team_id = record.id
      when [Member]
        # Find overlap in teams between current user and given member
        team_members = as_team_staf ? record.team_members.staff : record.team_members
        team_members = team_members.active if member?
        team_id = team_members.pluck(:team_id).uniq
      when [PlayerEvaluation]
        team_id = record.team_evaluation.team_id
      when [TeamMember], [TeamEvaluation], [Note], [TrainingSchedule], [Training]
        team_id = record.team_id
      when [Comment]
        team_id = record.commentable_id if record.commentable_type == "Team"
        team_id = record.commentable.active_team&.id if record.commentable_type == "Member"
      when [Presence]
        team_id = if record.presentable_type == "Match"
                    record.presentable.teams.pluck(:id)
                  else
                    record.presentable.team_id
                  end
      when [Match]
        team_id = record.teams.pluck(:id)
      end

      team_id
    end
end
