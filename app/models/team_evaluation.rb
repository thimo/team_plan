class TeamEvaluation < ApplicationRecord
  belongs_to :team, required: true
  belongs_to :invited_by, class_name: "User", required: false
  belongs_to :finished_by, class_name: "User", required: false
  has_many :player_evaluations, dependent: :destroy

  attr_accessor :enable_validation

  accepts_nested_attributes_for :player_evaluations
  validates_associated :player_evaluations

  scope :asc, -> { order(created_at: :asc) }
  scope :desc, -> { order(created_at: :desc) }

  def draft?
    team.draft?
  end

  def active?
    team.active?
  end

  def archived?
    team.archived?
  end

  def enable_validation?
    enable_validation || false
  end

  def finish_evaluation(user)
    self.update_attribute(:finished_by, user)
    self.update_attribute(:finished_at, DateTime.now)
  end

  def send_invites(user)
    mail_count = 0

    team.team_members.staff.each do |team_member|
      # Check account
      user = User.find_or_create_and_invite(team_member.member.email)
      TeamEvaluationMailer.invite(user, self).deliver_now

      mail_count += 1
    end

    if mail_count > 0
      self.update_attribute(:invited_by, user)
      self.update_attribute(:invited_at, DateTime.now)
    end

    return mail_count
  end

  def status
    if finished_at.present?
      "Afgerond"
    elsif invited_at.present?
      "In behandeling"
    else
      "Te versturen"
    end
  end
end
