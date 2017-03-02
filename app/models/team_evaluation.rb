class TeamEvaluation < ApplicationRecord
  belongs_to :team, required: true
  belongs_to :invited_by, class_name: "User"
  belongs_to :finished_by, class_name: "User"
  has_many :evaluations, dependent: :destroy

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
end
