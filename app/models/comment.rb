class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  enum comment_type: {generic: 0, technique: 1, behaviour: 2, classification: 3, membership: 4}

  validates_presence_of :body
end
