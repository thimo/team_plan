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

  default_scope -> {joins(:member).order('members.last_name ASC, members.first_name ASC') }

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
