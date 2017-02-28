class TeamEvaluation < ApplicationRecord
  belongs_to :team, required: true
  has_many :evaluations, dependent: :destroy
  accepts_nested_attributes_for :evaluations

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
