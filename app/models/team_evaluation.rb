# frozen_string_literal: true

class TeamEvaluation < ApplicationRecord
  multi_tenant :tenant
  belongs_to :team, required: true
  belongs_to :invited_by, class_name: "User", required: false
  belongs_to :finished_by, class_name: "User", required: false
  has_many :player_evaluations, dependent: :destroy
  has_paper_trail

  attr_accessor :enable_validation

  accepts_nested_attributes_for :player_evaluations
  validates_associated :player_evaluations

  scope :asc, -> { order(created_at: :asc) }
  scope :desc, -> { order(created_at: :desc) }
  scope :invited, -> { where.not(invited_at: nil) }
  scope :open_at_team, -> { where(finished_at: nil).where.not(invited_at: nil) }
  scope :finished, -> { where.not(finished_at: nil) }
  scope :desc_finished, -> { order(finished_at: :desc) }
  scope :by_team, ->(team) { includes(:team).where(team: team) }
  scope :by_age_group, ->(age_group) { joins(:team).where(teams: { age_group: age_group }) }

  delegate :draft?, to: :team
  delegate :active?, to: :team
  delegate :archived?, to: :team

  def enable_validation?
    enable_validation || false
  end

  def finish_evaluation(user)
    update_attribute(:finished_by, user)
    update_attribute(:finished_at, Time.zone.now)
  end

  def send_invites(user)
    users = []
    Member.by_team(team).team_staff.distinct.each do |member|
      # Check account
      users << User.find_or_create_and_invite(member)
    end

    if users.any?
      TeamEvaluationMailer.invite(users, self).deliver_now
      update_attribute(:invited_by, user)
      update_attribute(:invited_at, Time.zone.now)
    end

    users.size
  end

  def finished?
    finished_at.present?
  end

  def invited?
    invited_at.present?
  end

  def open?
    !invited? && !finished?
  end

  def status
    if finished?
      "Afgerond"
    elsif invited?
      "Open bij team"
    else
      "Te versturen"
    end
  end

  def progress
    return @calculated_progress if @calculated_progress.present?

    filled_fields = 0

    player_evaluations.each do |player_evaluation|
      PlayerEvaluation::RATING_FIELDS.each do |rating_field|
        filled_fields += 1 if player_evaluation[rating_field].present?
      end
      filled_fields += 1 if player_evaluation.advise_next_season.present?
    end

    total_field_count = player_evaluations.size * (PlayerEvaluation::RATING_FIELDS.size + 1)

    @calculated_progress = (100 * filled_fields) / total_field_count
  end

  def last_modified
    [updated_at, player_evaluations.maximum(:updated_at)].max
  end
end
