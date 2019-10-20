# Evaluates a single player
class PlayerEvaluation < ApplicationRecord
  RATING_FIELDS = %w[behaviour technique handlingspeed insight passes speed locomotion physical endurance
                     duel_strength].freeze
  RATING_OPTIONS = [["zeer goed", "9"], %w[goed 8], %w[voldoende 6], %w[matig 5], %w[onvoldoende 4]].freeze
  ADVISE_NEXT_SEASON_OPTIONS = %w[hoger zelfde lager].freeze

  acts_as_tenant :tenant
  belongs_to :team_evaluation, touch: true
  belongs_to :team_member, touch: true
  has_paper_trail

  validates :behaviour, :technique, :handlingspeed, :insight, :passes, :speed, :locomotion, :physical, :endurance,
            :duel_strength, :advise_next_season, :prefered_foot,
            presence: true, if: -> { team_evaluation.enable_validation? && team_member.active? }
  # Make sure linked team member has field positions filled in
  validate :team_member_has_field_positions, if: -> { team_evaluation.enable_validation? && team_member.active? }

  delegate :prefered_foot, to: :team_member
  accepts_nested_attributes_for :team_member

  default_scope -> { joins(team_member: :member).order("members.last_name ASC, members.first_name ASC") }
  scope :finished, -> { joins(:team_evaluation).where.not(team_evaluations: { finished_at: nil }) }
  scope :finished_desc, -> { finished.joins(:team_evaluation).order("team_evaluations.finished_at DESC") }
  scope :includes_member, -> {
                            includes(:team_member)
                              .includes(team_member: :member)
                              .includes(team_member: :field_positions)
                          }
  scope :for_team, ->(team) { includes(team_member: :team).where(team_members: { team: team }) }
  scope :for_season, ->(season) {
                       includes(team_member: { team: :age_group })
                         .where(age_groups: { season_id: season.id })
                     }
  scope :not_private, -> { joins(:team_evaluation).where(team_evaluations: { private: false }) }
  scope :public_or_as_team_staff, ->(user) {
    joins(:team_evaluation)
      .where("(team_evaluations.private = false and team_members.member_id IN (?)) OR team_evaluations.team_id IN (?)",
             user.member_ids, user.teams_as_staff.map(&:id))
  }

  delegate :draft?, to: :team_evaluation
  delegate :active?, to: :team_evaluation
  delegate :archived?, to: :team_evaluation

  def prefered_foot=(prefered_foot)
    team_member.update(prefered_foot: prefered_foot) if team_member.prefered_foot != prefered_foot
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

    rating
  end

  private

    def team_member_has_field_positions
      errors.add("field_positions", "Team member heeft geen field position") if team_member.field_positions.blank?
    end
end
