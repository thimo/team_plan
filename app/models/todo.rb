class Todo < ApplicationRecord
  belongs_to :user
  belongs_to :todoable, polymorphic: true

  scope :asc,      -> { order(created_at: :asc) }
  scope :desc,     -> { order(created_at: :desc) }
  scope :open,     -> { where(finished: false) }
  scope :finished, -> { where(finished: true) }
  scope :active,   -> { where(started_on: nil).or(where("started_on <= ?", Date.today)) }
  scope :defered,  -> { where("started_on > ?", Date.today) }

  def due?
    ended_on.present? && ended_on < Time.now
  end

  def defered?
    started_on.present? && started_on > Time.now
  end

end
