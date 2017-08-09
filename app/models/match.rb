class Match < ApplicationRecord
  belongs_to :team
  has_many :presences, as: :presentable, dependent: :destroy

  attr_accessor :start_time

  validates_presence_of :started_at, :team_id

  # Accessors for time aspects of start date
  def start_time
    started_at.to_time if started_at.present?
  end

  def start_time=(time)
    self.started_at = started_at.change(hour: time[4], min: time[5]) unless started_at.nil?
  end

end
