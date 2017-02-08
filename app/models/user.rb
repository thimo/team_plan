class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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

  def has_member?(member)
    self.members.where(id: member.id).size > 0
  end

  def is_team_member_for?(record)
    if record.class == TeamMember
      return self.members.joins(:team_members).where(team_members: {team_id: record.team_id}).size > 0
    end

    false
  end

  def is_team_staff_for?(record)
    if record.class == Team
      return self.members.joins(:team_members).where(team_members: {team_id: record.id, role: [1, 2, 3]}).size > 0
    end

    if record.class == TeamMember
      return self.members.joins(:team_members).where(team_members: {team_id: record.team_id, role: [1, 2, 3]}).size > 0
    end

    false
  end
end
