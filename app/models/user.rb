class User < ApplicationRecord
  include Filterable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :registerable, :confirmable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :favorites, dependent: :destroy
  has_many :email_logs, dependent: :destroy
  has_many :logs, dependent: :destroy
  has_many :todos
  has_one :user_setting
  has_paper_trail

  # Add conditional validation on first_name and last_name, not executed for devise
  validates_presence_of :email

  enum role: {member: 0, admin: 1, club_staff: 2}

  scope :asc, -> { order(last_name: :asc, first_name: :asc) }
  scope :role, -> (role) { where(role: role) }
  scope :query, -> (query) { where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")}

  # Setter
  def name=(name)
    split = name.split(' ', 2)
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
    if self.name == self.email
      self.email
    else
      %("#{self.name}" <#{self.email}>)
    end
  end

  def members
    Member.where("lower(email) = ?", email.downcase)
  end

  def active_teams
    member_ids = members.map(&:id).uniq
    Team.joins(:team_members).where(team_members: {member_id: member_ids}).joins(age_group: :season).where(seasons: {status: Season.statuses[:active]}).distinct.asc
  end

  def teams_as_staff_in_season(season)
    member_ids = members.map(&:id).uniq
    Team.joins(:team_members).where(team_members: {member_id: member_ids, role: TeamMember::STAFF_ROLES}).joins(age_group: :season).where(age_groups: {season: season}).distinct.asc
  end

  def has_member?(member)
    self.members.where(id: member.id).size > 0
  end

  def is_team_member_for?(record)
    case [record.class]
    when [Member]
      # Find overlap in teams between current user and given member
      team_members = record.team_members
      team_members = team_members.active_or_archived if member?
      team_ids = team_members.pluck(:team_id).uniq
      return self.members.joins(:team_members).where(team_members: {team_id: team_ids}).size > 0
    when [Team]
      team_ids = record.id
      return self.members.joins(:team_members).where(team_members: {team_id: team_ids}).size > 0
    else
      false
    end
  end

  def is_team_staff_for?(record)
    team_id = 0

    case [record.class]
    when [Team]
      team_id = record.id
    when [TeamMember]
      team_id = record.team_id
    when [Member]
      team_members = record.team_members
      team_members = team_members.active_or_archived if member?
      team_id = team_members.pluck(:team_id).uniq
    when [TeamEvaluation]
      team_id = record.team_id
    when [PlayerEvaluation]
      team_id = record.team_evaluation.team_id
    end

    return team_id != 0 && self.members.joins(:team_members).where(team_members: {team_id: team_id, role: TeamMember::STAFF_ROLES}).size > 0
  end

  def favorite_teams
    @favorite_teams ||= Team.joins(:favorites).where(favorites: {user_id: id, favorable_type: Team.to_s})
  end

  def favorite_age_groups
    @favorite_age_groups ||= AgeGroup.joins(:favorites).where(favorites: {user_id: id, favorable_type: AgeGroup.to_s})
  end

  def has_favorite?(member)
    @favorite_members ||= favorites.where(favorable_type: Member.to_s).pluck(:id)
    @favorite_members.include?(member.id)
  end

  def set_new_password
    self.password = Devise.friendly_token.first(8)
  end

  def send_new_account(password)
    UserMailer.new_account_notification(self, password).deliver_now
  end

  def send_password_reset(password)
    UserMailer.password_reset(self, password).deliver_now
  end

  def self.find_or_create_and_invite(member)
    user = User.where(email: member.email).first_or_initialize(
      password: (generated_password = Devise.friendly_token.first(8)),
      first_name: member.first_name,
      middle_name: member.middle_name,
      last_name: member.last_name,
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
    user_setting || self.create_user_setting
  end
end
