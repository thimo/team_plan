class Training < ApplicationRecord
  include Activatable
  include Presentable

  belongs_to :team
  belongs_to :training_schedule, optional: true

  attr_accessor :start_time, :end_time

  validates_presence_of :started_at, :ended_at, :team_id

  scope :not_modified, -> { where(user_modified: false) }
  scope :from_now,     -> { where('started_at > ?', Time.zone.now) }
  scope :in_past,      -> { where('started_at < ?', Time.zone.now) }
  scope :this_week,    -> (date) { where('started_at > ?', date.beginning_of_week).where('started_at < ?', date.end_of_week) }
  scope :in_period,    -> (start_date, end_date) { where('started_at > ?', start_date).where('started_at < ?', end_date)}
  scope :asc,          -> { order(started_at: :asc) }
  scope :desc,         -> { order(started_at: :desc) }

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
    "Training #{Setting['club.name_short']} #{team.name}"
  end

  def description
    "#{training_schedule.soccer_field.name} #{training_schedule.field_part_i18n}" if training_schedule&.soccer_field
  end

  def location
    "#{Setting['club.sportscenter']}\\n#{Setting['club.address']}\\n#{Setting['club.zip']}  #{Setting['club.city']}"
  end
end
