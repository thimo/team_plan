# == Schema Information
#
# Table name: matches
#
#  id                       :bigint           not null, primary key
#  accommodatie             :string
#  adres                    :string
#  afgelast                 :boolean          default(FALSE)
#  afgelast_status          :string
#  edit_level               :integer          default("knvb")
#  eigenteam                :boolean          default(FALSE)
#  ends_at                  :datetime
#  plaats                   :string
#  postcode                 :string
#  remark                   :text
#  route                    :string
#  telefoonnummer           :string
#  thuisteam                :string
#  thuisteamclubrelatiecode :string
#  thuisteamid              :integer
#  uitslag                  :string
#  uitslag_at               :datetime
#  uitteam                  :string
#  uitteamclubrelatiecode   :string
#  uitteamid                :integer
#  user_modified            :boolean          default(FALSE)
#  website_referee          :string
#  wedstrijd                :string
#  wedstrijdcode            :integer
#  wedstrijddatum           :datetime
#  wedstrijdnummer          :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  competition_id           :bigint
#  created_by_id            :bigint
#  tenant_id                :bigint
#
# Indexes
#
#  index_matches_on_competition_id  (competition_id)
#  index_matches_on_created_by_id   (created_by_id)
#  index_matches_on_tenant_id       (tenant_id)
#  index_matches_on_wedstrijdcode   (tenant_id,wedstrijdcode) UNIQUE
#
class Match < ApplicationRecord
  include Presentable

  acts_as_tenant :tenant
  belongs_to :competition
  belongs_to :created_by, class_name: "User", optional: true
  has_and_belongs_to_many :teams
  has_paper_trail

  validates :wedstrijdcode, :wedstrijddatum, presence: true
  validates :opponent, presence: true, if: -> { new_record? && !competition.knvb? }
  validates :thuisteam, :uitteam, presence: true, if: -> { !new_record? }
  validates :wedstrijdcode, uniqueness: {scope: :tenant}

  attr_accessor :opponent, :is_home_match

  enum edit_level: {knvb: 0, beheer_oefenwedstrijden: 1, team_staff: 2}

  scope :asc, -> { order(:wedstrijddatum) }
  scope :desc, -> { order(wedstrijddatum: :desc) }
  scope :in_period, ->(start_date, end_date) {
    where("wedstrijddatum > ?", start_date).where("wedstrijddatum < ?", end_date)
  }
  scope :from_now, -> { where("wedstrijddatum > ?", Time.zone.now) }
  scope :from_today, -> { where("wedstrijddatum > ?", Time.zone.today) }
  scope :in_past, -> { where("wedstrijddatum < ?", Time.zone.now) }
  scope :played, -> { where.not(uitslag: nil) }
  scope :not_played, -> { where(uitslag: nil) }
  scope :own, -> { where(eigenteam: true) }
  scope :uitslag_at, -> { order(uitslag_at: :desc) }
  scope :afgelast, -> { where(afgelast: true) }
  scope :niet_afgelast, -> { where(afgelast: false) }
  scope :active, -> { where(afgelast: false) }
  scope :for_team, ->(team_ids) { includes(:teams).where(teams: {id: team_ids}) }
  scope :for_competition, ->(competition_ids) { where(competition_id: competition_ids) }
  scope :with_referee, -> { where.not(website_referee: nil) }

  before_validation :check_wedstrijdcode

  def started_at
    wedstrijddatum
  end

  def minutes_per_half
    return 45.minutes if (team = teams.first).blank?

    (team.minutes_per_half || team.age_group.minutes_per_half).minutes
  end

  def pause_minutes
    15.minutes
  end

  def ended_at
    if toernooi? && ends_at.present?
      ends_at
    else
      wedstrijddatum + (2 * minutes_per_half) + pause_minutes
    end
  end

  def title
    return "Toernooi #{thuisteam}" if toernooi?

    title = "#{thuisteam} - #{uitteam}"
    title += " (#{uitslag})" if uitslag.present?
    title
  end

  def schedule_title
    return "Toernooi" if toernooi?

    title
  end

  def description
    remark
  end

  def full_address
    [accommodatie, adres, "#{postcode} #{plaats}"]
  end

  def location
    full_address.compact.join("\\n")
  end

  def google_maps_address
    full_address.compact.join(",")
  end

  def team_name
    teams.first.name
  end

  def set_uitslag(data_uitslag)
    data_uitslag = nil if data_uitslag.blank? || data_uitslag.strip == "-"
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

  def end_time
    (ends_at.presence || (wedstrijddatum + 4.hours)).to_time
  end

  def end_time=(time)
    self.ends_at = wedstrijddatum.change(hour: time[4], min: time[5]) unless wedstrijddatum.nil?
  end

  def self.new_match_datetime
    Time.zone.tomorrow.at_middle_of_day
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

  def toernooi?
    competition.competitiesoort == "toernooi"
  end

  def type_name
    toernooi? ? "toernooi" : "wedstrijd"
  end

  def referee
    website_referee
  end

  def self.new_custom_wedstrijdcode
    # Custom competitions have a wedstrijdcode < 0
    [order(:wedstrijdcode).first.wedstrijdcode, 0].min - 1
  end

  private

  def check_wedstrijdcode
    self.wedstrijdcode = Match.new_custom_wedstrijdcode if wedstrijdcode.blank?
  end
end
