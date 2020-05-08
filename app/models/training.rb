# == Schema Information
#
# Table name: trainings
#
#  id                   :bigint           not null, primary key
#  active               :boolean          default(TRUE)
#  body                 :text
#  ended_at             :datetime
#  remark               :text
#  started_at           :datetime
#  user_modified        :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  team_id              :bigint
#  tenant_id            :bigint
#  training_schedule_id :bigint
#
# Indexes
#
#  index_trainings_on_team_id               (team_id)
#  index_trainings_on_tenant_id             (tenant_id)
#  index_trainings_on_training_schedule_id  (training_schedule_id)
#
class Training < ApplicationRecord
  include Activatable
  include Presentable

  acts_as_tenant :tenant
  belongs_to :team
  belongs_to :training_schedule, optional: true
  has_paper_trail

  validates :started_at, :ended_at, :team_id, presence: true

  scope :not_modified, -> { where(user_modified: false) }
  scope :from_now, -> { where("started_at > ?", Time.zone.now) }
  scope :in_past, -> { where("started_at < ?", Time.zone.now) }
  scope :this_week, ->(date) {
                      where("started_at > ?", date.beginning_of_week)
                        .where("started_at < ?", date.end_of_week)
                    }
  scope :in_period, ->(start_date, end_date) {
                      where("started_at > ?", start_date)
                        .where("started_at < ?", end_date)
                    }
  scope :asc, -> { order(started_at: :asc) }
  scope :desc, -> { order(started_at: :desc) }
  scope :with_program, -> { where.not(body: nil).where.not(body: "") }

  # Accessors for time aspects of start and end dates
  def start_time
    started_at.to_time if started_at.present?
  end

  def start_time=(time)
    self.started_at = started_at.change(hour: time[4], min: time[5]) unless started_at.nil?
  end

  def end_time
    ended_at.to_time if ended_at.present?
  end

  def end_time=(time)
    self.ended_at = started_at.change(hour: time[4], min: time[5]) unless started_at.nil?
  end

  def title
    "#{schedule_title} #{team.name_with_club}"
  end

  def schedule_title
    "Training"
  end

  def description
    [
      "#{training_schedule&.soccer_field&.name} #{training_schedule&.field_part_i18n}".strip,
      remark
    ].reject(&:blank?).join("\n\n")
  end

  def location
    "#{Tenant.setting("club_sportscenter")}\\n#{Tenant.setting("club_address")}\\n#{Tenant.setting("club_zip")} \
     #{Tenant.setting("club_city")}"
  end
end
