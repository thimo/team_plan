class Injury < ApplicationRecord
  belongs_to :user
  belongs_to :member
  has_paper_trail

  validates_presence_of :started_on, :title

  scope :desc, -> { order(created_at: :desc) }

end
