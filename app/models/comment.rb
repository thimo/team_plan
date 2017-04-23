class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_paper_trail

  enum comment_type: {generic: 0, technique: 1, behaviour: 2, classification: 3, membership: 4}

  validates_presence_of :body

  scope :desc, -> { order(created_at: :desc) }
  scope :half_year, -> { where("created_at >= ?", 6.months.ago) }
end
