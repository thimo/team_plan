class ClubDataMatch < ApplicationRecord
  include Presentable

  belongs_to :club_data_competition
  has_and_belongs_to_many :teams

  scope :asc, -> { order(:wedstrijddatum) }
  scope :desc, -> { order(wedstrijddatum: :desc) }
  scope :in_period, -> (start_date, end_date) {
    where('wedstrijddatum > ?', start_date).where('wedstrijddatum < ?', end_date)
  }
  scope :from_now, -> { where('wedstrijddatum > ?', Time.zone.now) }
  scope :played, -> { where.not(uitslag: nil) }
  scope :not_played, -> { where(uitslag: nil) }
  scope :own, -> { where(eigenteam: true) }

  def started_at
    wedstrijddatum
  end

  def ended_at
    wedstrijddatum + 2.hours
  end

  def title
    wedstrijd
  end

  def description
    nil
  end

  def location
    "#{accommodatie}\\n#{plaats}"
  end

  def team_name
    teams.first.name
  end
end
