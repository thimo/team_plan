class TeamEvaluation < ApplicationRecord
  belongs_to :team, required: true
  belongs_to :invited_by, class_name: "User", required: false
  belongs_to :finished_by, class_name: "User", required: false
  has_many :evaluations, dependent: :destroy

  attr_accessor :enable_validation

  accepts_nested_attributes_for :evaluations
  validates_associated :evaluations

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

  def finish_evaluation(current_user)
    self.update_attribute(:finished_by, current_user)
    self.update_attribute(:finished_at, DateTime.now)
  end
end
