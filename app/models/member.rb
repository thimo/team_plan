# frozen_string_literal: true

# Imported members from Sportlink
class Member < ApplicationRecord
  include Filterable
  include PgSearch

  mount_uploader :photo, PhotoUploader

  STATUS_DEFINITIEF = "definitief"
  STATUS_AF_TE_MELDEN = "af te melden"
  STATUS_OVERSCHRIJVING_SPELACTIVITEIT = "overschrijving spelactiviteit"

  EXPORT_COLUMNS = %w[season age_group team association_number name full_name last_name first_name middle_name born_on
                      gender role address zipcode city phone email email_2 member_since previous_team].freeze
  EXPORT_COLUMNS_EVALUATION = %w[field_positions prefered_foot advise_next_season].freeze
  DEFAULT_COLUMNS = %w[team association_number name born_on role address zipcode city phone email email_2].freeze
  EMAIL_ADDRESSES = %w[email email_2 email_parent email_parent_2].freeze

  acts_as_tenant :tenant
  has_many :team_members, dependent: :destroy
  has_many :team_members_as_player, -> { where(role: TeamMember.roles[:player]) },
           class_name: "TeamMember", inverse_of: :member
  has_many :teams, through: :team_members
  has_many :teams_as_player, through: :team_members_as_player, class_name: "Team", source: :team
  has_many :org_position_members, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :player_evaluations, through: :team_members
  has_many :logs, as: :logable, dependent: :nullify
  has_many :todos, as: :todoable, dependent: :nullify
  has_many :injuries, dependent: :destroy
  has_many :presences, dependent: :destroy
  has_many :play_bans, dependent: :destroy
  has_many :group_members, dependent: :destroy
  has_and_belongs_to_many :users
  has_paper_trail

  validates :last_name, :born_on, :gender, :association_number, presence: true

  scope :asc, -> { order(last_name: :asc, first_name: :asc) }
  scope :to_year,   ->(year) { where("born_on <= ?", Time.zone.local(year).end_of_year.to_date) }
  scope :from_year, ->(year) { where("born_on >= ?", Time.zone.local(year).beginning_of_year.to_date) }
  scope :active, -> {
    where(deregistered_at: nil).or(where("deregistered_at > ?", Time.zone.today))
  }
  scope :active_for_season, ->(season) {
    where(deregistered_at: nil).or(where("deregistered_at > ?", season.started_on))
  }
  scope :inactive, -> { where.not(deregistered_at: nil).where("deregistered_at <= ?", Time.zone.today) }
  scope :recent_members, ->(days_ago) {
                           where("registered_at >= ?", days_ago.days.ago.beginning_of_day)
                             .order(registered_at: :desc, created_at: :desc)
                         }

  scope :active_for_month, ->(date) {
    active_before_end_of_month(date).inactive_after_end_of_month(date)
  }
  scope :active_before_end_of_month, ->(date) {
    where("registered_at <= ?", date.end_of_month.to_date)
  }
  scope :inactive_after_end_of_month, ->(date) {
    where(deregistered_at: nil)
      .or(where("deregistered_at > ?", date.end_of_month.to_date))
  }
  scope :activated_for_month, ->(date) {
    where("registered_at <= ? AND registered_at >= ?", date.end_of_month.to_date, date.beginning_of_month.to_date)
  }
  scope :deactivated_for_month, ->(date) {
    where("deregistered_at <= ? AND deregistered_at >= ?", date.end_of_month.to_date, date.beginning_of_month.to_date)
  }

  scope :sportlink_player, -> {
    where.not(sport_category: nil)
         .or(where(status: STATUS_OVERSCHRIJVING_SPELACTIVITEIT))
  }
  scope :sportlink_non_player, -> {
    where(sport_category: nil)
      .where.not(status: STATUS_OVERSCHRIJVING_SPELACTIVITEIT)
  }

  scope :male,   -> { where(gender: "M") }
  scope :female, -> { where(gender: "V") }
  scope :gender, ->(gender) { where(gender: gender) }
  scope :player, -> { includes(:team_members).where(team_members: { role: TeamMember.roles[:player] }) }
  scope :team_staff, -> { joins(:team_members).where.not(team_members: { role: TeamMember.roles[:player] }) }
  scope :injured, -> { where(injured: true) }

  scope :by_season, ->(season) { includes(team_members: { team: :age_group }).where(age_groups: { season_id: season }) }
  scope :by_season_as_player, ->(season) {
    includes(team_members: { team: :age_group }).where(age_groups: { season_id: season },
                                                       team_members: { role: TeamMember.roles[:player],
                                                                       ended_on: nil,
                                                                       status: 1 })
  }
  scope :by_age_group, ->(age_group) { includes(team_members: :team).where(teams: { age_group_id: age_group }) }
  scope :by_age_group_as_player, ->(age_group) {
    includes(team_members: :team).where(teams: { age_group_id: age_group },
                                        team_members: { role: TeamMember.roles[:player] })
  }
  scope :by_team, ->(team) { joins(:team_members).where(team_members: { team: team, ended_on: nil }) }
  scope :not_in_team, -> { includes(team_members: { team: :age_group }).where(age_groups: { season_id: nil }) }
  scope :active_in_a_team, -> { includes(:team_members).where(team_members: { ended_on: nil }) }
  scope :by_field_position, ->(field_positions) {
                              includes(team_members: :field_positions)
                                .where(field_positions: { id: field_positions })
                            }
  scope :by_email, ->(email) {
    where(EMAIL_ADDRESSES.map { |mail| "lower(#{mail}) = ?" }.join(" OR "),
          *([email.downcase] * EMAIL_ADDRESSES.size))
  }

  scope :with_active_play_ban, -> {
    joins(:play_bans).where("play_bans.started_on <= ? AND (play_bans.ended_on >= ? OR play_bans.ended_on IS null)",
                            Time.zone.today, Time.zone.today)
  }
  scope :with_future_play_ban, -> { joins(:play_bans).where("play_bans.started_on > ?", Time.zone.today) }

  scope :local_teams, ->(local_team) { where("local_teams like ?", "%#{local_team}%") }

  scope :query, ->(query) {
                  where("email ILIKE ? OR email_2 ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?",
                        "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
                }
  pg_search_scope :search_by_name,
                  against: [:first_name, :middle_name, :last_name, :email, :email2, :phone, :phone2],
                  using: {
                    tsearch: { prefix: true }
                  },
                  ignoring: :accents

  before_save :update_users

  def name
    "#{first_name} #{middle_name} #{last_name}".squish
  end

  def name_and_born_on
    "#{name} (#{I18n.l(born_on, format: :long)})"
  end

  def active?
    deregistered_at.nil? || deregistered_at > Time.zone.today
  end

  def inactive?
    !active?
  end

  def archived?
    inactive?
  end

  def favorite?(user)
    favorites.where(user: user).size.positive?
  end

  def favorite(user)
    favorites.find_by(user: user)
  end

  def teams_for_season(season)
    Team.for_season(season).for_members(self)
  end

  def active_team
    @active_team ||= teams_as_player.for_active_season.first || teams.for_active_season.first
  end

  def active_team_member
    @active_team_member ||= team_members.player.joins(team: { age_group: :season })
                                        .find_by(seasons: { status: Season.statuses[:active] })
  end

  def evaluation_for_season(season)
    player_evaluations.for_season(season).finished_desc.first
  end

  def evaluation_for_team(team)
    player_evaluations.for_team(team).finished_desc.first
  end

  def last_evaluation
    player_evaluations.finished_desc.first
  end

  def active_field_position?(field_positions)
    active? && (field_positions & active_team_member.field_positions.map(&:id)).present?
  end

  def status_definitief?
    status == STATUS_DEFINITIEF
  end

  def status_af_te_melden?
    status == STATUS_AF_TE_MELDEN
  end

  def self.comment_types
    Comment.comment_types
  end

  def user
    # TODO: When in the future a member can belong to multiple users by coupling to multiple emailaddresses,
    # than this (and other functionality using this) needs to change
    users.first
  end

  def reactivated?
    (registered_at - member_since).to_i > 30
  end

  def update_injured
    update(injured: injuries.active.any?)
  end

  def photo_data=(data)
    io = CarrierStringIO.new(Base64.decode64(data))
    self.photo = io
  end

  def full_address
    [address, "#{zipcode} #{city}"]
  end

  def google_maps_address
    full_address.join(",")
  end

  def self.import(file)
    result = { counters: { imported: 0, changed: 0 }, created: [], activated: [], member_ids: [] }

    check_header_translations(file)

    CSV.foreach(
      file.path,
      headers: true,
      header_converters: ->(h) { I18n.t("member.import.#{h.downcase.tr(' ', '_ ')}") }
    ) do |row|
      row_hash = row.to_hash
      association_number = row_hash["association_number"]
      member = Member.find_or_initialize_by(association_number: association_number)

      row_hash.each do |key, value|
        if Member.column_names.include?(key)
          if key.ends_with?("_at") || key.ends_with?("_since")
            member.send("#{key}=", value.to_date)
          else
            member.send("#{key}=", value.presence)
          end
        end
      end

      result[:counters][:imported] += 1

      result[:activated] << member if member.deregistered_at_was.present? && member.deregistered_at.nil?

      if member.new_record?
        result[:created] << member
        member.save!
      elsif member.changed?
        result[:counters][:changed] += 1
        member.save!
      end
      result[:member_ids] << member.id
    end

    Tenant.set_setting("last_import.members", Time.zone.now)

    result
  end

  def self.cleanup(imported_before, imported_member_ids)
    # `cleanup` works with `imported_at` because it can happen that members disappear from
    # from the Sportlink export. It would prob. be better to handle this in the import
    result = { deregistered: [] }

    Member.active.each do |member|
      if imported_member_ids.include? member.id
        # Member was imported, make sure `missed_import_on` is cleared
        member.update(missed_import_on: nil) if member.missed_import_on.present?
      else
        # Member was not in import. Set `missed_import_on` if nil
        member.update(missed_import_on: Time.zone.now) if member.missed_import_on.nil?
        if member.missed_import_on < imported_before
          member.update(deregistered_at: member.missed_import_on)
          result[:deregistered] << member
        end
      end
    end

    result
  end

  def self.export_columns(user)
    Member::EXPORT_COLUMNS + (user.show_evaluations? ? Member::EXPORT_COLUMNS_EVALUATION : [])
  end

  # Early notification of changed Sportlink export headers
  def self.check_header_translations(file)
    first_line = File.open(file.path) { |f| f.readline }
    header = first_line.strip.split(",").compact
    missing = header.select { |h| I18n.t("member.import.#{h.downcase.tr(' ', '_ ')}", default: nil).blank? }
    return if missing.none?

    ActionMailer::Base.mail(from: Tenant.setting("application.email"),
                            to: Tenant.setting("application.sysadmin.email"),
                            subject: "Missing member import headers (#{ActsAsTenant.current_tenant.name})",
                            body: missing.join("\n")).deliver
  end

  def emails
    EMAIL_ADDRESSES.map { |mail| send(mail) }.compact.uniq
  end

  def play_ban?
    play_bans.active.any?
  end

  private

    def update_users
      if new_record?
        EMAIL_ADDRESSES.each do |mail|
          add_to_user(send(mail))
        end
      elsif inactive?
        EMAIL_ADDRESSES.each do |mail|
          remove_from_user(send("#{mail}_was")) if send("#{mail}_changed?")
          remove_from_user(send(mail))
        end
      else
        EMAIL_ADDRESSES.each do |mail|
          if send("#{mail}_changed?")
            remove_from_user(send("#{mail}_was"))
            add_to_user(send(mail))
          end
        end
      end
    end

    def add_to_user(email)
      return if email.blank?

      if (user = User.by_email(email).first).present?
        users << user
        user.activate
      end
    end

    def remove_from_user(email)
      return if email.blank?

      if (user = User.by_email(email).first).present?
        user.members.delete(self)
        user.deactivate if user.members.none?
      end
    end
end
