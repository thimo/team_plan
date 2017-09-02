class Match < ApplicationRecord
  include Activatable
  include Presentable

  PLAYER_COUNT = [6, 7, 8, 9, 11]
  MINUTES_PER_HALF = [20, 25, 30, 35, 40, 45]

  belongs_to :team

  attr_accessor :start_time

  enum location: {location_home: 0, location_opponent: 1}

  validates_presence_of :started_at, :team_id

  # scope :from_now,     -> { where('started_at > ?', Time.zone.now) }
  # scope :this_week,    -> (date) { where('started_at > ?', date.beginning_of_week).where('started_at < ?', date.end_of_week) }
  scope :in_period, -> (start_date, end_date) { where('started_at > ?', start_date).where('started_at < ?', end_date)}
  scope :played, -> { where.not(goals_self: nil, goals_opponent: nil) }
  scope :not_played, -> { where(goals_self: nil, goals_opponent: nil) }

  delegate :name, to: :team, :prefix => true

  # Accessors for time aspects of start date
  def start_time
    started_at.to_time if started_at.present?
  end

  def start_time=(time)
    self.started_at = started_at.change(hour: time[4], min: time[5]) unless started_at.nil?
  end

  def thuisteam
    location_opponent? ? opponent : "#{Setting['club.name_short']} #{team.name}"
  end

  def uitteam
    location_opponent? ? "#{Setting['club.name_short']} #{team.name}" : opponent
  end

  def uitslag
    nil
  end
end
