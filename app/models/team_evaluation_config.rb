# Defines the configuration for a TeamEvaluation
# - name
# - status
# - fields
class TeamEvaluationConfig < ApplicationRecord
  include Statussable

  DEFAULT_CONFIG = {
    fields: [
      { label: "Gedrag", answers: "rating_5" },
      { label: "Techniek", answers: "rating_5" },
      { label: "Handelingssnelheid", answers: "rating_5" },
      { label: "Inzicht/Overzicht", answers: "rating_5" },
      { label: "Passen/Trappen", answers: "rating_5" },
      { label: "Snelheid", answers: "rating_5" },
      { label: "Motoriek", answers: "rating_5" },
      { label: "Fysiek", answers: "rating_5" },
      { label: "Uithoudingsvermogen", answers: "rating_5" },
      { label: "Duelkracht", answers: "rating_5" }
    ],
    answers: {
      rating_5: {
        "9": "zeer goed",
        "8": "goed",
        "6": "voldoende",
        "5": "matig",
        "4": "onvoldoende"
      }
    }
  }.freeze

  validates :name, presence: true

  scope :asc, -> { order(:name) }

  def config_raw
    JSON.pretty_generate(config)
  end

  def config_raw=(value)
    self.config = JSON(value)
  end
end
