class ClubDataMatch < ApplicationRecord
  include Presentable

  belongs_to :club_data_competition
  belongs_to :team, optional: true

  scope :asc, -> { order(:wedstrijddatum) }
  scope :in_period, -> (start_date, end_date) {
    where('wedstrijddatum > ?', start_date).where('wedstrijddatum < ?', end_date)
  }
  scope :from_now, -> { where('wedstrijddatum > ?', Time.zone.now) }

  delegate :name, to: :team, :prefix => true

  def started_at
    wedstrijddatum
  end
end
