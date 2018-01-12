class Todo < ApplicationRecord
  belongs_to :user
  belongs_to :todoable, polymorphic: true, optional: true

  scope :asc,      -> { order(created_at: :asc) }
  scope :desc,     -> { order(created_at: :desc) }
  scope :unfinished,     -> { where(finished: false) }
  scope :finished, -> { where(finished: true) }
  scope :active,   -> { where(started_on: nil).or(where("started_on <= ?", Time.zone.today)) }
  scope :defered,  -> { where("started_on > ?", Time.zone.today) }

  def due?
    ended_on.present? && ended_on < Time.zone.now
  end

  def defered?
    started_on.present? && started_on > Time.zone.now
  end

end
