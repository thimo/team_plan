# frozen_string_literal: true

class Comment < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :user
  belongs_to :commentable, polymorphic: true, touch: true
  has_paper_trail

  enum comment_type: { generic: 0, technique: 1, behaviour: 2, classification: 3, membership: 4 }

  validates :body, presence: true

  scope :desc, -> { order(created_at: :desc) }
  scope :half_year, -> { where("created_at >= ?", 6.months.ago) }
  scope :season, ->(season) {
    where("created_at >= ? AND created_at <= ?", season&.started_on || 100.years.ago, season&.ended_on || Time.zone.now)
  }

  def self.active_tab(user, parent, tab)
    user.active_comments_tab = tab if tab.present?

    if parent.class.comment_types.include? user.settings.active_comments_tab
      user.settings.active_comments_tab
    else
      "generic"
    end
  end
end
