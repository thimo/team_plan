class TrainingSchedule < ApplicationRecord
  belongs_to :team
  belongs_to :soccer_field

  validates_presence_of :day, :start_time, :end_time, :soccer_field_id, :field_part

  enum day: {monday: 0, tuesday: 1, wednesday: 2, thursday: 3, friday: 4, saturday: 5, sunday: 6}
  enum field_part: {whole: 0, ab: 5, a: 1, b: 2, cd: 6, c: 3, d: 4}

end
