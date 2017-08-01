class Training < ApplicationRecord
  include Activatable

  belongs_to :training_schedule

  validates_presence_of :starts_at, :ends_at, :training_schedule_id
end
