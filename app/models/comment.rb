class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  scope :generic, -> { where(comment_type: Comment.comment_types[:generic]) }
  scope :technique, -> { where(comment_type: Comment.comment_types[:technique]) }
  scope :behaviour, -> { where(comment_type: Comment.comment_types[:behaviour]) }
  scope :classification, -> { where(comment_type: Comment.comment_types[:classification]) }
  scope :membership, -> { where(comment_type: Comment.comment_types[:membership]) }

  enum comment_type: {generic: 0, technique: 1, behaviour: 2, classification: 3, membership: 4}

  validates_presence_of :body
end
