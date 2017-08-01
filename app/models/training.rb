class Training < ApplicationRecord
  include Activatable

  belongs_to :training_schedule

  validates_presence_of :starts_at, :ends_at, :training_schedule_id

  scope :not_modified, -> { where(user_modified: false) }
  scope :from_now, -> { where('starts_at > ?', DateTime.now) }
  scope :this_week, -> (date) { where('starts_at > ?', date.beginning_of_week).where('starts_at < ?', date.end_of_week) }
end
