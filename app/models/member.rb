class Member < ApplicationRecord
  include Filterable
  include PgSearch

  STATUS_DEFINITIEF = 'definitief'
  STATUS_AF_TE_MELDEN = 'af te melden'
  STATUS_OVERSCHRIJVING_SPELACTIVITEIT = 'overschrijving spelactiviteit'

  has_many :team_members, dependent: :destroy
  has_many :team_members_as_player, -> { where(role: TeamMember.roles[:player]) }, class_name: 'TeamMember'
  has_many :teams, through: :team_members
  has_many :teams_as_player, through: :team_members_as_player, class_name: 'Team', source: :team

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :player_evaluations, through: :team_members
  has_many :logs, as: :logable
  has_many :todos, as: :todoable
  has_paper_trail

  scope :asc, -> { order(last_name: :asc, first_name: :asc) }
  scope :from_year, -> (year) { where("born_on >= ?", Date.new(year).beginning_of_year) }
  scope :to_year, -> (year) { where("born_on <= ?", Date.new(year).end_of_year) }
  scope :sportlink_active, -> { where(deregistered_at: nil).or(where("deregistered_at > ?", Date.today)) }
  scope :sportlink_player, -> { where("sport_category <> ''").or(where(status: STATUS_OVERSCHRIJVING_SPELACTIVITEIT)) }
  scope :male, -> { where(gender: "M") }
  scope :female, -> { where(gender: "V") }
  scope :by_team, -> (team) { joins(:team_members).where(team_members: {team: team}) }
  scope :team_staff, -> { joins(:team_members).where(team_members: {role: TeamMember::STAFF_ROLES}) }
  scope :query, -> (query) { where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")}
  scope :by_season, -> (season) { includes(team_members: {team: :age_group}).where(age_groups: {season_id: season}) }
  # 2017-07-02 This scope to be renamed 'player' after a testing period. 'player' existed previously, must be sure that it's renamed everywhere
  scope :as_player, -> { includes(:team_members).where(team_members: { role: TeamMember.roles[:player] }) }
  scope :active_in_a_team, -> { includes(:team_members).where(team_members: { ended_on: nil }) }
  scope :by_field_position, -> (field_positions) { includes(team_members: :field_positions).where(field_positions: {id: field_positions}) }
  scope :recent_members, -> (days_ago) { where("registered_at >= ?", days_ago.days.ago.to_date).order(registered_at: :desc) }

  pg_search_scope :search_by_name,
    against: [:first_name, :middle_name, :last_name, :email, :email2],
    using:  {
              tsearch: {prefix: true}
            },
    ignoring: :accents

  def name
    "#{first_name} #{middle_name} #{last_name}".squish
  end

  def reversed_name
    "#{last_name}, #{first_name} #{middle_name}".squish
  end

  def name_and_born_on
    "#{name} (#{I18n.l(born_on, format: :long)})"
  end

  def is_favorite?(user)
    favorites.where(user: user).size > 0
  end

  def favorite(user)
    favorites.where(user: user).first
  end

  def teams_for_season(season)
    Team.for_season(season).for_members(self)
  end

  def active_team
    @active_team ||= teams_as_player.for_active_season.first || teams.for_active_season.first
  end

  def active_team_member
    @active_team_member ||= team_members.player.joins(team: {age_group: :season}).where(seasons: {status: Season.statuses[:active]}).first
  end

  def evaluation_for_season(season)
    player_evaluations.for_season(season).finished_desc.first
  end

  def active?
    active_team_member.present?
  end

  def has_active_field_position?(field_positions)
    active? && (field_positions & active_team_member.field_positions.map(&:id)).present?
  end

  def status_definitief?
    status == STATUS_DEFINITIEF
  end

  def status_af_te_melden?
    status == STATUS_AF_TE_MELDEN
  end

  def comment_types
    Comment.comment_types
  end

  def user
    @user ||= User.where("lower(email) = ?", email.downcase).first
  end

  def reactivated?
    (registered_at - member_since).to_i > 30
  end

  def self.import(file)
    result = { counters: { imported: 0, changed: 0 }, created: [], activated: [] }

    CSV.foreach(file.path, :headers => true,
                           :header_converters => lambda { |h| I18n.t("member.import.#{h.downcase.gsub(' ', '_')}") }
                           ) do |row|
      row_hash = row.to_hash
      association_number = row_hash["association_number"]
      member = Member.find_or_initialize_by(association_number: association_number)
      result[:created] << member if member.new_record?

      old_deregistered_at = member.deregistered_at
      row_hash.each do |key, value|
        if Member.column_names.include?(key)
          if key.ends_with?("_at") || key.ends_with?("_since")
            member.send("#{key}=", value.to_date)
          else
            member.send("#{key}=", value.present? ? value : nil)
          end
        end
      end

      result[:counters][:imported] += 1
      if member.changed?
        result[:counters][:changed] += 1
      end
      result[:activated] << member if old_deregistered_at.present? && member.deregistered_at.nil?

      member.imported_at = DateTime.now
      member.save!
    end

    result
  end

  def self.cleanup(imported_before)
    result = { deregistered: [] }
    Member.where(deregistered_at: nil).where('imported_at < ?', imported_before).each do |member|
      member.deregistered_at = member.imported_at
      member.save
      result[:deregistered] << member
    end

    result
  end
end
