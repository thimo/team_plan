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

  def send_invite(user)
    # TODO
    # Invite all team staff members. Create accounts if needed
    # Error if no team staff was found
    TeamEvaluationMailer.invite(user, self).deliver_now
    self.update_attribute(:invited_by, user)
    self.update_attribute(:invited_at, DateTime.now)
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
