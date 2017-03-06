class Member < ApplicationRecord
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :evaluations, through: :team_members

  scope :asc, -> { order(last_name: :asc, first_name: :asc) }

  scope :from_year, lambda {|year| where("born_on >= ?", "#{year}-01-01")}
  scope :to_year, lambda {|year| where("born_on <= ?", "#{year}-12-31")}
  scope :active_players, -> {where("sport_category <> ''").where(status: "definitief")}
  scope :male, -> { where(gender: "M") }
  scope :female, -> { where(gender: "V") }

  def name
    "#{first_name} #{middle_name} #{last_name}".squish
  end

  def is_favorite?(user)
    favorites.where(user: user).size > 0
  end

  def favorite(user)
    favorites.where(user: user).first
  end

  def last_evaluation
    evaluations.finished_desc.first
  end

  def active_team
    teams.joins(age_group: :season).where(seasons: {status: Season.statuses[:active]}).first
  end

  def active_team_member
    team_members.player.joins(team: {age_group: :season}).where(seasons: {status: Season.statuses[:active]}).first
  end

  def self.import(file)
    CSV.foreach(file.path, :headers => true,
                           :header_converters => lambda { |h| I18n.t("member.import.#{h.downcase.gsub(' ', '_')}") }
                           ) do |row|
      row_hash = row.to_hash
      association_number = row_hash["association_number"]
      member = Member.find_or_initialize_by(association_number: association_number)

      row_hash.each do |k, v|
        member.send("#{k}=", v) if Member.column_names.include?(k) && !v.blank?
      end

      member.imported_at = DateTime.now
      member.save!
    end
  end
end
