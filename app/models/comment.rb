class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  enum comment_type: {comment_generic: 0, comment_technique: 1, comment_behaviour: 2, comment_classification: 3}

  validates_presence_of :body
end
