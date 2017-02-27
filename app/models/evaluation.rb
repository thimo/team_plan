class Evaluation < ApplicationRecord
  belongs_to :team_evaluation
  belongs_to :member

  def draft?
    team_evaluation.draft?
  end

  def active?
    team_evaluation.active?
  end

  def archived?
    team_evaluation.archived?
  end
end
