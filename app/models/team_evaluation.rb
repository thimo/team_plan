# == Schema Information
#
# Table name: team_evaluations
#
#  id                      :integer          not null, primary key
#  config                  :jsonb
#  finished_at             :datetime
#  hide_remark_from_player :boolean          default(FALSE)
#  invited_at              :datetime
#  private                 :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  finished_by_id          :bigint
#  invited_by_id           :bigint
#  team_id                 :integer
#  tenant_id               :bigint
#
# Indexes
#
#  index_team_evaluations_on_finished_by_id  (finished_by_id)
#  index_team_evaluations_on_invited_by_id   (invited_by_id)
#  index_team_evaluations_on_team_id         (team_id)
#  index_team_evaluations_on_tenant_id       (tenant_id)
#

# Evaluates the players in a team
class TeamEvaluation < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :team, optional: false
  belongs_to :invited_by, class_name: "User", optional: true
  belongs_to :finished_by, class_name: "User", optional: true
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
  scope :by_age_group, ->(age_group) { joins(:team).where(teams: {age_group: age_group}) }

  delegate :draft?, to: :team
  delegate :active?, to: :team
  delegate :archived?, to: :team

  def enable_validation?
    enable_validation || false
  end

  def finish_evaluation(user)
    update(finished_by: user, finished_at: Time.zone.now)
  end

  def send_invites(user)
    members = Member.by_team(team).team_staff.distinct

    if members.any?
      members.each do |member|
        # Check account
        User.find_or_create_and_invite(member)
      end
      # Don't use `deliver_later`, does not seem to work correctly yet
      TeamEvaluationMailer.invite(Current.user, members, self).deliver_now
      update(invited_by: user, invited_at: Time.zone.now)
    end

    members.size
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
      config["fields"].each_with_index do |_field, index|
        filled_fields += 1 if player_evaluation["field_#{index + 1}"].present?
      end
      filled_fields += 1 if player_evaluation.advise_next_season.present?
    end

    total_field_count = player_evaluations.size * (config["fields"].size + 1)

    @calculated_progress = (100 * filled_fields) / total_field_count
  end

  def last_modified
    [updated_at, player_evaluations.maximum(:updated_at)].max
  end

  def config_json
    config.to_json
  end

  def config_json=(value)
    self.config = JSON(value)
  end
end
