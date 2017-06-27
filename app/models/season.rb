class Season < ApplicationRecord
  include Statussable

  has_many :age_groups, dependent: :destroy
  has_paper_trail

  validates_presence_of :name, :status

  scope :asc, -> { order(name: :asc) }
  scope :desc, -> { order(name: :desc) }
  scope :active_or_archived, -> { where(status: [Season.statuses[:archived], Season.statuses[:active]]) }

  def status_children
    # Only propagate status when archiving
    archived? ? age_groups : []
  end

  def previous
    # TODO properly policy_scope
    self.class.where("created_at < ?", created_at).order(created_at: :asc).last
  end

  def next
    # TODO properly policy_scope
    self.class.where("created_at > ?", created_at).order(created_at: :asc).first
  end

end
