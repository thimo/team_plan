class Member < ApplicationRecord
  include Filterable

  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :player_evaluations, through: :team_members

  scope :asc, -> { order(last_name: :asc, first_name: :asc) }

  scope :from_year, -> (year) { where("born_on >= ?", Date.new(year).beginning_of_year) }
  scope :to_year, -> (year) { where("born_on <= ?", Date.new(year).end_of_year) }
  scope :active, -> { where(status: "definitief").or(where("deregistered_at > ?", Date.today)) }
  scope :player, -> { where("sport_category <> ''") }
  scope :male, -> { where(gender: "M") }
  scope :female, -> { where(gender: "V") }
  scope :by_team, -> (team) { joins(:team_members).where(team_members: {team: team}) }
  scope :team_staff, -> { joins(:team_members).where(team_members: {role: TeamMember::STAFF_ROLES}) }
  scope :query, -> (query) { where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")}

  def name
    "#{first_name} #{middle_name} #{last_name}".squish
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

  def active_team
    teams.joins(age_group: :season).where(seasons: {status: Season.statuses[:active]}).first
  end

  def active_team_member
    team_members.player.joins(team: {age_group: :season}).where(seasons: {status: Season.statuses[:active]}).first
  end

  def last_evaluation
    active_team_member.player_evaluations.finished_desc.first if active_team_member.present?
  end

  def active?
    active_team_member.present?
  end

  def has_active_field_position?(field_positions)
    active? && (field_positions & active_team_member.field_positions.map(&:id)).present?
  end

  def self.import(file)
    CSV.foreach(file.path, :headers => true,
                           :header_converters => lambda { |h| I18n.t("member.import.#{h.downcase.gsub(' ', '_')}") }
                           ) do |row|
      row_hash = row.to_hash
      association_number = row_hash["association_number"]
      member = Member.find_or_initialize_by(association_number: association_number)

      row_hash.each do |key, value|
        if Member.column_names.include?(key) && !value.blank?
          if key.ends_with?("_at") || key.ends_with?("_since")
            member.send("#{key}=", value.to_date)
          else
            member.send("#{key}=", value)
          end
        end
      end

      member.imported_at = DateTime.now
      member.save!
    end
  end
end
