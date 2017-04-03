class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :favorites, dependent: :destroy
  has_many :email_logs, dependent: :destroy

  # Add conditional validation on first_name and last_name, not executed for devise
  validates_presence_of :email

  enum role: {member: 0, admin: 1, club_staff: 2}

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
    %("#{self.name}" <#{self.email}>)
  end

  def members
    Member.where("lower(email) = ?", email.downcase)
  end

  def active_teams
    member_ids = members.map(&:id)
    Team.joins(:team_members).where(team_members: {member_id: member_ids}).joins(age_group: :season).where(seasons: {status: Season.statuses[:active]}).distinct.asc
  end

  def has_member?(member)
    self.members.where(id: member.id).size > 0
  end

  def is_team_member_for?(record)
    if record.class == Member
      # Find overlap in teams between current user and given member
      team_ids = record.team_members.pluck(:team_id).uniq
      return self.members.joins(:team_members).where(team_members: {team_id: team_ids}).size > 0
    end

    false
  end

  def is_team_staff_for?(record)
    team_id = 0

    case record.class
    when Team
      team_id = record.id
    when Member
      team_id = record.team_members.pluck(:team_id).uniq
    when TeamEvaluation
      team_id = record.team_id
    when Evaluation
      team_id = record.team_evaluation.team_id
    end

    return team_id > 0 && self.members.joins(:team_members).where(team_members: {team_id: team_id, role: [1, 2, 3]}).size > 0
  end

  def favorite_teams
    Team.joins(:favorites).where(favorites: {user_id: id, favorable_type: Team.to_s})
  end

  def favorite_age_groups
    AgeGroup.joins(:favorites).where(favorites: {user_id: id, favorable_type: AgeGroup.to_s})
  end

  def has_favorite?(member)
    @favorite_members ||= favorites.where(favorable_type: Member.to_s).pluck(:id)
    @favorite_members.include?(member.id)
  end

  def invite(password)
    UserMailer.new_account_notification(self, password).deliver_now
  end

  def self.find_or_create_and_invite(email)
    user = User.where(email: email).first_or_initialize(password: (generated_password = Devise.friendly_token.first(8)))

    if user.new_record?
      user.save
      user.invite(generated_password)
    end

    user
  end
end
