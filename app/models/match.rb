# frozen_string_literal: true

class Match < ApplicationRecord
  include Presentable

  validates :wedstrijdcode, :wedstrijddatum, :thuisteam, :uitteam, presence: true
  validates :wedstrijdcode, uniqueness: true

  belongs_to :competition
  belongs_to :created_by, class_name: "User", required: false
  has_and_belongs_to_many :teams
  has_paper_trail

  attr_accessor :opponent, :is_home_match, :team_id

  enum edit_level: { knvb: 0, club_staff: 1, team_staff: 2 }

  scope :asc,             -> { order(:wedstrijddatum) }
  scope :desc,            -> { order(wedstrijddatum: :desc) }
  scope :in_period,       ->(start_date, end_date) {
    where("wedstrijddatum > ?", start_date).where("wedstrijddatum < ?", end_date)
  }
  scope :from_now,        -> { where("wedstrijddatum > ?", Time.zone.now) }
  scope :from_today,      -> { where("wedstrijddatum > ?", Time.zone.today) }
  scope :in_past,         -> { where("wedstrijddatum < ?", Time.zone.now) }
  scope :played,          -> { where.not(uitslag: nil) }
  scope :not_played,      -> { where(uitslag: nil) }
  scope :own,             -> { where(eigenteam: true) }
  scope :uitslag_at,      -> { order(uitslag_at: :desc) }
  scope :afgelast,        -> { where(afgelast: true) }
  scope :niet_afgelast,   -> { where(afgelast: false) }
  scope :active,          -> { where(afgelast: false) }
  scope :for_team,        ->(team_ids) { includes(:teams).where(teams: { id: team_ids }) }
  scope :for_competition, ->(competition_ids) { where(competition_id: competition_ids) }

  def started_at
    wedstrijddatum
  end

  def minutes_per_half
    team = teams.first
    (team&.minutes_per_half || team&.age_group&.minutes_per_half || 45).minutes
  end

  def pause_minutes
    15.minutes
  end

  def ended_at
    wedstrijddatum + (2 * minutes_per_half) + pause_minutes
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
    full_address.join(",")
  end

  def team_name
    teams.first.name
  end

  def set_uitslag(data_uitslag)
    data_uitslag = nil if data_uitslag.strip == "-"
    self.uitslag = data_uitslag
    self.uitslag_at = Time.zone.now if uitslag_changed?
  end

  # Accessors for time aspects of start and end dates
  def wedstrijdtijd
    wedstrijddatum.to_time if wedstrijddatum.present?
  end

  def wedstrijdtijd=(time)
    self.wedstrijddatum = wedstrijddatum.change(hour: time[4], min: time[5]) unless wedstrijddatum.nil?
  end

  def self.new_custom_wedstrijdcode
    # Custom competitions have a wedstrijdcode < 0
    [order(:wedstrijdcode).first.wedstrijdcode, 0].min - 1
  end

  def self.new_match_datetime
    Time.zone.today.at_middle_of_day
  end

  def wedstrijddatum_date
    wedstrijddatum.to_date
  end

  def active?
    !afgelast?
  end

  def inactive?
    !active?
  end
end
