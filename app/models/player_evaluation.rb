class PlayerEvaluation < ApplicationRecord
  RATING_OPTIONS = [["goed", "8"], ["voldoende", "6"], ["matig", "5"], ["onvoldoende", "4"]]
  ADVISE_NEXT_SEASON_OPTIONS = %w(hoger zelfde lager)

  # copy field_position and prefered_foot to team_member on after_validation because after_save only gets triggered when PlayerEvaluation values have been updated
  after_validation :copy_to_team_member

  belongs_to :team_evaluation, required: true
  belongs_to :team_member, required: true

  validates_presence_of :behaviour, :technique, :handlingspeed, :insight, :passes, :speed, :locomotion, :physical, :endurance, :duel_strength, :advise_next_season, :field_position, :prefered_foot, if: ->{ team_evaluation.enable_validation? }

  attr_accessor :prefered_foot, :field_position

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

  private

    def copy_to_team_member
      team_member.update_attribute(:prefered_foot, prefered_foot) if prefered_foot.present? && team_member.prefered_foot != prefered_foot
      team_member.update_attribute(:field_position, field_position) if field_position.present? && team_member.field_position != field_position
      true
    end
end
