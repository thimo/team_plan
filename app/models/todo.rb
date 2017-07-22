class Todo < ApplicationRecord
  belongs_to :user
  belongs_to :todoable, polymorphic: true

  scope :asc,      -> { order(created_at: :asc) }
  scope :desc,     -> { order(created_at: :desc) }
  scope :open,     -> { where(finished: false) }
  scope :finished, -> { where(finished: true) }
  scope :active,     -> { where(starts_on: nil).or(where("starts_on <= ?", Date.today)) }
  scope :defered,  -> { where("starts_on > ?", Date.today) }

  def due?
    ends_on.present? && ends_on < Time.now
  end

  def defered?
    starts_on.present? && starts_on > Time.now
  end

end
