class Match < ApplicationRecord
  include Presentable

  validates_presence_of :wedstrijdcode, :wedstrijddatum, :thuisteam, :uitteam
  validates_uniqueness_of :wedstrijdcode

  belongs_to :competition
  has_and_belongs_to_many :teams

  attr_accessor :wedstrijdtijd #, :end_time

  scope :asc,           -> { order(:wedstrijddatum) }
  scope :desc,          -> { order(wedstrijddatum: :desc) }
  scope :in_period,     -> (start_date, end_date) { where('wedstrijddatum > ?', start_date).where('wedstrijddatum < ?', end_date) }
  scope :from_now,      -> { where('wedstrijddatum > ?', Time.zone.now) }
  scope :in_past,       -> { where('wedstrijddatum < ?', Time.zone.now) }
  scope :played,        -> { where.not(uitslag: nil) }
  scope :not_played,    -> { where(uitslag: nil) }
  scope :own,           -> { where(eigenteam: true) }
  scope :uitslag_at,    -> { order(uitslag_at: :desc) }
  scope :afgelast,      -> { where(afgelast: true) }
  scope :niet_afgelast, -> { where(afgelast: false) }
  scope :active,        -> {}
  scope :for_team,      -> (team_ids) { includes(:teams).where(teams: { id: team_ids }) }

  def started_at
    wedstrijddatum
  end

  def ended_at
    # Fixed time for ical calendar
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
    data_uitslag = nil if data_uitslag.strip == '-'

    if uitslag != data_uitslag
      self.uitslag = data_uitslag
      self.uitslag_at = Time.zone.now
      save
    end
  end

  # Accessors for time aspects of start and end dates
  def wedstrijdtijd
    wedstrijddatum.to_time if wedstrijddatum.present?
  end

  def wedstrijdtijd=(time)
    self.wedstrijddatum = wedstrijddatum.change(hour: time[4], min: time[5]) unless wedstrijddatum.nil?
  end

  # def end_time
  #   ended_at.to_time if ended_at.present?
  # end

  # def end_time=(time)
  #   self.ended_at = started_at.change(hour: time[4], min: time[5]) unless started_at.nil?
  # end

  def self.new_custom_wedstrijdcode
    # Custom competitions have a wedstrijdcode < 0
    [order(:wedstrijdcode).first.wedstrijdcode, 0].min - 1
  end

  def self.new_match_datetime
    Time.zone.today.at_middle_of_day
  end
end
