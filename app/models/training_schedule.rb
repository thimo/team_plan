class TrainingSchedule < ApplicationRecord
  include Activatable
  include Presentable

  after_save :update_trainings

  belongs_to :team
  belongs_to :soccer_field
  has_many :trainings, dependent: :destroy
  has_and_belongs_to_many :team_members
  has_paper_trail

  validates_presence_of :day, :start_time, :end_time, :soccer_field_id, :field_part

  enum day: {monday: 0, tuesday: 1, wednesday: 2, thursday: 3, friday: 4, saturday: 5, sunday: 6}
  enum field_part: {whole: 0, part_ab: 5, part_a: 1, part_b: 2, part_cd: 6, part_c: 3, part_d: 4}
  enum present_minutes: {min_0: 0, min_5: 5, min_10: 10, min_15: 15, min_30: 30, min_45: 45, min_60: 60}

  scope :asc, -> { order(:day) }

  def update_trainings
    # Don't create trainings if training schedule was archived or if season has no end date
    return if !active? || team.age_group.season.ended_on.nil?

    if trainings.any?
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
        training.save
      end
    else
      # Create new trainings
      training_day = next_training_day
      while training_day <= team.age_group.season.ended_on
        started_at = training_day.change(hour: start_time.hour, min: start_time.min)
        ended_at = training_day.change(hour: end_time.hour, min: end_time.min)

        Training.create(
          training_schedule: self,
          team: self.team,
          started_at: started_at,
          ended_at: ended_at,
        ) unless has_training_this_week?(started_at)

        training_day += 7.days
      end
    end
  end

  def day_number
    TrainingSchedule.days[day]
  end

  private

    def has_training_this_week?(started_at)
      trainings.this_week(started_at).present?
    end

    def next_training_day
      training_day = Time.zone.now.beginning_of_week + day_number.days
      training_day += 7.days if training_day.end_of_day <= Time.zone.today.end_of_day
      training_day
    end

end
