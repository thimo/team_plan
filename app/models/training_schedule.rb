# == Schema Information
#
# Table name: training_schedules
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE)
#  cios            :boolean          default(FALSE)
#  day             :integer
#  end_time        :time
#  ended_on        :date
#  field_part      :integer
#  present_minutes :integer          default("min_0")
#  start_time      :time
#  started_on      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  soccer_field_id :bigint
#  team_id         :bigint
#  tenant_id       :bigint
#
# Indexes
#
#  index_training_schedules_on_soccer_field_id  (soccer_field_id)
#  index_training_schedules_on_team_id          (team_id)
#  index_training_schedules_on_tenant_id        (tenant_id)
#
class TrainingSchedule < ApplicationRecord
  include Activatable
  include Presentable

  after_save :update_trainings

  acts_as_tenant :tenant
  belongs_to :team
  belongs_to :soccer_field
  has_many :trainings, dependent: :destroy
  has_and_belongs_to_many :team_members
  has_paper_trail

  validates :day, :start_time, :end_time, :soccer_field_id, :field_part, presence: true

  enum day: { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 0 }
  enum field_part: { whole: 0, part_ab: 5, part_a: 1, part_b: 2, part_cd: 6, part_c: 3, part_d: 4 }
  enum present_minutes: { min_0: 0, min_5: 5, min_10: 10, min_15: 15, min_30: 30, min_45: 45, min_60: 60 }

  scope :asc, -> { order(:day) }

  def update_trainings
    # Don't create trainings if training schedule was archived or has no end date
    return if !active? || started_on.nil? || ended_on.nil?

    # Remove future trainings of start/end date changed
    trainings.from_now.destroy_all if saved_change_to_started_on? || saved_change_to_ended_on?

    if trainings.from_now.any?
      # Update existing trainings
      trainings.from_now.each do |training|
        if saved_change_to_day?
          difference = TrainingSchedule.days[day] - TrainingSchedule.days[day_before_last_save]
          training.started_at += difference.days
          training.ended_at += difference.days
        end
        if saved_change_to_start_time?
          training.started_at = training.started_at.change(hour: start_time.hour, min: start_time.min)
        end
        if saved_change_to_end_time?
          training.ended_at = training.ended_at.change(hour: end_time.hour, min: end_time.min)
        end
        training.save!
      end
    else
      # Create new trainings
      training_day = next_training_day
      while training_day <= ended_on
        started_at = training_day.change(hour: start_time.hour, min: start_time.min)
        ended_at = training_day.change(hour: end_time.hour, min: end_time.min)

        unless training_this_week?(started_at)
          Training.create(
            training_schedule: self,
            team: team,
            started_at: started_at,
            ended_at: ended_at
          )
        end

        training_day += 7.days
      end
    end
  end

  def day_number
    TrainingSchedule.days[day]
  end

  def deactivate
    super

    trainings.from_now.destroy_all
  end

  private

    def training_this_week?(started_at)
      trainings.this_week(started_at).present?
    end

    def next_training_day
      next_wday([started_on.beginning_of_day, Time.zone.now].max, day_number)
    end

    def next_wday(from_date, wday)
      skip_week_in_days = wday >= from_date.wday ? 0 : 7
      from_date + (skip_week_in_days - from_date.wday + wday).days
    end
end
