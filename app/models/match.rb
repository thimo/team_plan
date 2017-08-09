class Match < ApplicationRecord
  include Activatable
  include Presentable

  belongs_to :team

  attr_accessor :start_time

  validates_presence_of :started_at, :team_id

  # scope :from_now,     -> { where('started_at > ?', Time.zone.now) }
  # scope :this_week,    -> (date) { where('started_at > ?', date.beginning_of_week).where('started_at < ?', date.end_of_week) }
  scope :in_period, -> (start_date, end_date) { where('started_at > ?', start_date).where('started_at < ?', end_date)}

  # Accessors for time aspects of start date
  def start_time
    started_at.to_time if started_at.present?
  end

  def start_time=(time)
    self.started_at = started_at.change(hour: time[4], min: time[5]) unless started_at.nil?
  end

end
