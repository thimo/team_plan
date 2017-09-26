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
  scope :uitslag_at, -> { order(uitslag_at: :desc) }

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

  def full_address
    [accommodatie, adres, "#{postcode} #{plaats}"]
  end

  def location
    full_address.join("\\n")
  end

  def google_maps_address
    full_address.join(',')
  end

  def team_name
    teams.first.name
  end

  def update_uitslag(data_uitslag)
    # TODO remove uitslag_at check after a next sync
    if uitslag != data_uitslag || uitslag_at.nil?
      self.uitslag = data_uitslag
      self.uitslag_at = Time.zone.now
      save
    end
  end
end
