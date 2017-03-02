class Evaluation < ApplicationRecord
  RATING_OPTIONS = [["goed", "8"], ["voldoende", "6"], ["matig", "5"], ["onvoldoende", "4"]]
  FIELD_POSITION_OPTIONS = {
      "Aanval" => ["linksbuiten", "spits", "rechtsbuiten"],
      "Middenveld" => ["linkshalf", "centrale middenvelder", "rechtshalf"],
      "Verdediging" => ["linksachter", "voorstopper", "rechtsachter", "laatste man", "keeper"],
      "As" => ["linker as", "centrale as", "rechter as"],
      "Linie" => ["aanvaller", "middenvelder", "verdediger"],
      "Overig" => ["geen voorkeur"]
    }
  PREFERED_FOOT_OPTIONS = %w(rechtsbenig linksbenig tweebenig onbekend)
  ADVISE_NEXT_SEASON_OPTIONS = %w(hoger zelfde lager)

  belongs_to :team_evaluation, required: true
  belongs_to :member, required: true

  validates_presence_of :field_position, :prefered_foot, :behaviour, :technique, :handlingspeed, :insight, :passes, :speed, :locomotion, :physical, :endurance, :duel_strength, :advise_next_season, if: ->{ team_evaluation.enable_validation? }

  default_scope -> { joins(:member).order('members.last_name ASC, members.first_name ASC') }
  scope :finished, -> { joins(:team_evaluation).where.not(team_evaluations: {finished_at: nil}) }
  scope :finished_desc, -> { finished.joins(:team_evaluation).order('team_evaluations.finished_at DESC') }

  def draft?
    team_evaluation.draft?
  end

  def active?
    team_evaluation.active?
  end

  def archived?
    team_evaluation.archived?
  end

  def advise_to_icon_class
    case advise_next_season
    when Evaluation::ADVISE_NEXT_SEASON_OPTIONS[0]
      "fa-chevron-up"
    when Evaluation::ADVISE_NEXT_SEASON_OPTIONS[1]
      "fa-minus"
    when Evaluation::ADVISE_NEXT_SEASON_OPTIONS[2]
      "fa-chevron-down"
    end
  end

  def self.human_value_name_for_rating(rating)
    Evaluation::RATING_OPTIONS.each do |item|
      return item[0] if item.size >= 2 && item[1] == rating
    end

    return rating
  end
end
