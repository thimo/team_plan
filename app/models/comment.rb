# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text
#  comment_type     :integer          default("generic")
#  commentable_type :string
#  private          :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :integer
#  tenant_id        :bigint
#  user_id          :integer
#
# Indexes
#
#  index_comments_on_commentable_type_and_commentable_id  (commentable_type,commentable_id)
#  index_comments_on_tenant_id                            (tenant_id)
#  index_comments_on_user_id                              (user_id)
#
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
  scope :created_for_month, ->(date) {
    where("created_at <= ? AND created_at >= ?", date.end_of_month.to_date, date.beginning_of_month.to_date)
  }

  def self.active_tab(user, parent, tab)
    user.active_comments_tab = tab if tab.present?

    if parent.class.comment_types.include? user.setting(:active_comments_tab)
      user.setting(:active_comments_tab)
    else
      "generic"
    end
  end
end
