class Todo < ApplicationRecord
  belongs_to :user
  belongs_to :todoable, polymorphic: true

  scope :asc, -> { order(created_at: :asc) }
  scope :desc, -> { order(created_at: :desc) }
  scope :open, -> { where(finished: false) }
  scope :finished, -> { where(finished: true) }
end
