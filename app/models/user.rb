# frozen_string_literal: true

class User < ApplicationRecord
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
  has_many :group_members, through: :members
  has_many :all_groups, through: :group_members, source: :group
  has_many :direct_groups, -> { where(group_members: { memberable_type: nil, memberable_id: nil }) },
           through: :group_members,
           source: :group
  has_many :direct_roles, through: :direct_groups, source: :roles

  has_many :indirect_groups, -> { where.not(group_members: { memberable_type: nil, memberable_id: nil }) },
           through: :group_members,
           source: :group
  has_many :indirect_roles, through: :indirect_groups, source: :roles

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

  def active_age_groups
    AgeGroup.for_members(members).active.for_active_season.distinct
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

  # NOTE: can't rename this to `member?` because of conflict with enum role
  def has_member?(member)
    members.where(id: member.id).size.positive?
  end

  def team_member_for?(record)
    team_id = team_id_for(record)
    members.by_team(team_id).size.positive?
  end

  def team_staff_for?(record)
    team_id = team_id_for(record, true)
    members.by_team(team_id).team_staff.size.positive?
  end

  # def club_staff_for?(record)
  #   age_group_id = age_group_id_for(record)
  #   # Look up age_group_members as intersection between user's members and age_groups
  #   members.joins(:group_members)
  #          .where(group_members: { memberable_type: "AgeGroup", memberable_id: age_group_id }).size.positive?
  # end

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
    "Met dit account is het helaas niet mogelijk om in te loggen. Ga alsjeblieft zelf na of het e-mailadres dat \
    je gebruikt wel is gekoppeld aan een lidmaatschap in de ledenadministratie van #{Setting['club.name_short']}."
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

  def any_beheer_role?
    direct_role_names.any? { |role| role.start_with?("beheer_") }
  end

  def role?(role, record = nil)
    direct_role_names.include?(role.to_s) || indirect_role_names_for(record).include?(role.to_s)
  end

  def indirect_role?(role)
    indirect_role_names.include?(role.to_s)
  end

  def show_evaluations?
    admin? || role?(Role::MEMBER_SHOW_EVALUATIONS) || indirect_role?(Role::MEMBER_SHOW_EVALUATIONS)
  end

  private

    def team_id_for(record, as_team_staf = false)
      @team_id_for ||= {}
      key = [record, as_team_staf]
      @team_id_for[key] ||= case [record.class]
                            when [Team]
                              record.id
                            when [Member]
                              # Find overlap in teams between current user and given member
                              team_members = as_team_staf ? record.team_members.staff : record.team_members
                              team_members = team_members.active if member?
                              team_members.pluck(:team_id).uniq
                            when [PlayerEvaluation]
                              record.team_evaluation.team_id
                            when [TeamMember], [TeamEvaluation], [Note], [TrainingSchedule], [Training]
                              record.team_id
                            when [Comment]
                              if record.commentable_type == "Team"
                                record.commentable_id
                              elsif record.commentable_type == "Member"
                                record.commentable.active_team&.id
                              else
                                0
                              end
                            when [Presence]
                              if record.presentable_type == "Match"
                                record.presentable.teams.pluck(:id)
                              else
                                record.presentable.team_id
                              end
                            when [Match]
                              record.persisted? ? record.teams.pluck(:id) : record.teams.map(&:id)
                            else
                              0
                            end
    end

    def age_group_id_for(record)
      @age_group_id_for ||= {}
      @age_group_id_for[record] ||= case [record.class]
                                    when [AgeGroup]
                                      record.id
                                    when [Team]
                                      record.age_group_id # Included here to make sure it works for new Team objects
                                    else
                                      AgeGroup.draft_or_active.by_team(team_id_for(record)).pluck(:id)
                                    end
    end

    def direct_role_names
      @direct_role_names ||= direct_roles.distinct.pluck(:name)
    end

    # All role names from indirect groups, should only be used on special occasions. Preferred
    # way is through `indirect_role_names_for(record)``
    def indirect_role_names
      @indirect_role_names ||= indirect_roles.distinct.pluck(:name)
    end

    def indirect_role_names_for(record)
      return [] if record.nil?

      @indirect_role_names_for ||= {}
      @indirect_role_names_for[record] ||= indirect_roles_for(record).distinct.pluck(:name)
    end

    def indirect_roles_for(record)
      age_group_id = age_group_id_for(record)
      group = Group.for_member(members).for_memberable("AgeGroup", age_group_id)
      Role.by_group(group)
    end
end
