class PlayerEvaluation < ApplicationRecord
  RATING_FIELDS = %w(behaviour technique handlingspeed insight passes speed locomotion physical endurance duel_strength)
  RATING_OPTIONS = [["zeer goed", "9"], ["goed", "8"], ["voldoende", "6"], ["matig", "5"], ["onvoldoende", "4"]]
  ADVISE_NEXT_SEASON_OPTIONS = %w(hoger zelfde lager)

  belongs_to :team_evaluation, required: true
  belongs_to :team_member, required: true
  has_paper_trail

  validates_presence_of :behaviour, :technique, :handlingspeed, :insight, :passes, :speed, :locomotion, :physical, :endurance, :duel_strength, :advise_next_season, :prefered_foot, if: -> { team_evaluation.enable_validation? && team_member.active? }
  # Make sure linked team member has field positions filled in
  validate :team_member_has_field_positions, if: -> { team_evaluation.enable_validation? && team_member.active? }

  delegate :prefered_foot, to: :team_member
  accepts_nested_attributes_for :team_member

  default_scope -> { joins(team_member: :member).order('members.last_name ASC, members.first_name ASC') }
  scope :finished, -> { joins(:team_evaluation).where.not(team_evaluations: {finished_at: nil}) }
  scope :finished_desc, -> { finished.joins(:team_evaluation).order('team_evaluations.finished_at DESC') }
  scope :includes_member, -> {includes(:team_member).includes(team_member: :member).includes(team_member: :field_positions)}

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

  def advise_to_icon_class
    case advise_next_season
    when PlayerEvaluation::ADVISE_NEXT_SEASON_OPTIONS[0]
      "fa-arrow-circle-up"
    when PlayerEvaluation::ADVISE_NEXT_SEASON_OPTIONS[1]
      "fa-arrow-circle-right"
    when PlayerEvaluation::ADVISE_NEXT_SEASON_OPTIONS[2]
      "fa-arrow-circle-down"
    end
  end

  def self.human_value_name_for_rating(rating)
    PlayerEvaluation::RATING_OPTIONS.each do |item|
      return item[0] if item.size >= 2 && item[1] == rating
    end

    return rating
  end

  private

    def team_member_has_field_positions
      errors.add('field_positions', 'Team member heeft geen field position') if team_member.field_positions.blank?
    end

end
