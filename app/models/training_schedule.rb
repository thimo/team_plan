class TrainingSchedule < ApplicationRecord
  include Activatable

  after_save :update_trainings

  belongs_to :team
  belongs_to :soccer_field
  has_many :trainings, dependent: :destroy
  has_and_belongs_to_many :team_members
  has_paper_trail

  validates_presence_of :day, :start_time, :end_time, :soccer_field_id, :field_part

  enum day: {monday: 0, tuesday: 1, wednesday: 2, thursday: 3, friday: 4, saturday: 5, sunday: 6}
  enum field_part: {whole: 0, ab: 5, a: 1, b: 2, cd: 6, c: 3, d: 4}
  enum present_minutes: {min_0: 0, min_5: 5, min_10: 10, min_15: 15, min_30: 30, min_45: 45, min_60: 60}

  scope :asc, -> { order(:day) }

  def update_trainings
    # Remove all future, non-modified trainings
    trainings.from_now.not_modified.destroy_all

    training_day = next_training_day
    while training_day < team.age_group.season.ended_on
      started_at = training_day.change(hour: start_time.hour, min: start_time.min)
      ended_at = training_day.change(hour: end_time.hour, min: end_time.min)

      Training.create(
        training_schedule: self,
        started_at: started_at,
        ended_at: ended_at,
      ) unless has_training_this_week?(started_at)

      training_day = training_day.next_day(7)
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
      training_day = DateTime.now.beginning_of_week.next_day(day_number)
      training_day = training_day.next_day(7) if training_day <= Date.today
      training_day
    end

end
