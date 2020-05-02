# == Schema Information
#
# Table name: team_evaluation_configs
#
#  id         :bigint           not null, primary key
#  config     :jsonb
#  name       :string
#  status     :integer          default("draft")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :bigint
#
# Indexes
#
#  index_team_evaluation_configs_on_tenant_id  (tenant_id)
#

# Defines the configuration for a TeamEvaluation
# - name
# - status
# - fields
class TeamEvaluationConfig < ApplicationRecord
  acts_as_tenant :tenant
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
  validate :valid_config_json?

  scope :asc, -> { order(:name) }

  def config_json
    @config_json ||= JSON.pretty_generate(config)
  end

  def config_json=(value)
    @config_json = value
    self.config = JSON(value) if valid_json?(value)
  end

  private

    def valid_config_json?
      errors.add(:config_json, "is geen geldige JSON") unless valid_json?(config_json)
    end

    def valid_json?(value)
      JSON.parse(value).present?
    rescue JSON::ParserError
      false
    end
end
