class PlayerEvaluation < ApplicationRecord
  RATING_OPTIONS = [["zeer goed", "9"], ["goed", "8"], ["voldoende", "6"], ["matig", "5"], ["onvoldoende", "4"]]
  ADVISE_NEXT_SEASON_OPTIONS = %w(hoger zelfde lager)

  belongs_to :team_evaluation, required: true
  belongs_to :team_member, required: true

  validates_presence_of :behaviour, :technique, :handlingspeed, :insight, :passes, :speed, :locomotion, :physical, :endurance, :duel_strength, :advise_next_season, :field_position, :prefered_foot, if: -> { team_evaluation.enable_validation? }

  delegate :prefered_foot, :field_position, to: :team_member

  default_scope -> { joins(team_member: :member).order('members.last_name ASC, members.first_name ASC') }
  scope :finished, -> { joins(:team_evaluation).where.not(team_evaluations: {finished_at: nil}) }
  scope :finished_desc, -> { finished.joins(:team_evaluation).order('team_evaluations.finished_at DESC') }
  scope :includes_member, -> {includes(:team_member).includes(team_member: :member)}

  def draft?
    team_evaluation.draft?
  end

  def active?
    team_evaluation.active?
  end

  def archived?
    team_evaluation.archived?
  end

  def prefered_foot=(prefered_foot)
    team_member.update_columns(prefered_foot: prefered_foot) if team_member.prefered_foot != prefered_foot
  end

  def field_position=(field_position)
    team_member.update_columns(field_position: field_position) if team_member.field_position != field_position
  end

  def advise_to_icon_class
    case advise_next_season
    when PlayerEvaluation::ADVISE_NEXT_SEASON_OPTIONS[0]
      "fa-chevron-up"
    when PlayerEvaluation::ADVISE_NEXT_SEASON_OPTIONS[1]
      "fa-minus"
    when PlayerEvaluation::ADVISE_NEXT_SEASON_OPTIONS[2]
      "fa-chevron-down"
    end
  end

  def self.human_value_name_for_rating(rating)
    PlayerEvaluation::RATING_OPTIONS.each do |item|
      return item[0] if item.size >= 2 && item[1] == rating
    end

    return rating
  end

end
