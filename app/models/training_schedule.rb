class TrainingSchedule < ApplicationRecord
  include Activatable

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

end
