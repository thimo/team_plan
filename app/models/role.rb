# frozen_string_literal: true

class Role < ApplicationRecord
  acts_as_tenant :tenant
  has_and_belongs_to_many :users, join_table: :users_roles
  has_and_belongs_to_many :groups, join_table: :groups_roles

  AGE_GROUP_ROLES  = %w[AGE_GROUP_CREATE AGE_GROUP_UPDATE AGE_GROUP_SHOW_EVALUATIONS AGE_GROUP_SHOW_TODOS
                        AGE_GROUP_SHOW_MEMBER_COUNT AGE_GROUP_TEAM_ACTIONS].freeze
  BEHEER           = %w[BEHEER_ROLES BEHEER_GROUPS BEHEER_USERS BEHEER_MEMBERS
                        BEHEER_KNVB_CLUB_DATA BEHEER_OEFENWEDSTRIJDEN BEHEER_CONTRIBUTIE_SPEELVERBODEN
                        BEHEER_VERSION_UPDATES BEHEER_SETTINGS BEHEER_EMAIL_LOG BEHEER_COMPETITIONS
                        BEHEER_SOCCER_FIELDS].freeze
  COMMENT_ROLES    = %w[COMMENT_CREATE COMMENT_GENERIC COMMENT_TECHNIQUE COMMENT_BEHAVIOUR COMMENT_CLASSIFICATION
                        COMMENT_MEMBERSHIP].freeze
  DASHBOARD_ROLES  = %w[DASHBOARD_CEO_CHARTS].freeze
  INJURY_ROLES     = %w[INJURY_CREATE].freeze
  MEMBER_ROLES     = %w[MEMBER_SHOW_NEW MEMBER_SHOW_PRIVATE_DATA MEMBER_PREVIOUS_TEAM MEMBER_SHOW_EVALUATIONS
                        MEMBER_SHOW_FULL_BORN_ON MEMBER_SHOW_SPORTLINK_STATUS MEMBER_SHOW_CONDUCT
                        MEMBER_CREATE_EVALUATIONS].freeze
  NOTE_ROLES       = %w[NOTE_SHOW NOTE_CREATE].freeze
  PLAY_BAN_ROLES   = %w[PLAY_BAN_SHOW].freeze
  SEASON_ROLES     = %w[SEASON_INDEX SEASON_TEAM_ACTIONS].freeze
  STATUS_ROLES     = %w[STATUS_DRAFT].freeze
  TEAM_ROLES       = %w[TEAM_CREATE TEAM_DESTROY TEAM_SET_STATUS
                        TEAM_SHOW_EVALUATIONS TEAM_CREATE_EVALUATIONS TEAM_MEMBER_DOWNLOAD
                        TEAM_SHOW_COMMENTS TEAM_SHOW_NOTES TEAM_SHOW_STATISTICS TEAM_SHOW_TODOS].freeze
  TEAM_MEMB_ROLES  = %w[TEAM_MEMBER_CREATE TEAM_MEMBER_SET_ROLE TEAM_MEMBER_DESTROY TEAM_MEMBER_SET_STATUS].freeze
  TRA_SCHED_ROLES  = %w[TRAINING_SCHEDULE_CREATE].freeze
  TRAINING_ROLES   = %w[TRAINING_CREATE].freeze
  USER_ROLES       = %w[USER_SHOW USER_CREATE USER_EDIT USER_IMPERSONATE].freeze

  ROLES = BEHEER + DASHBOARD_ROLES + TEAM_ROLES + MEMBER_ROLES + AGE_GROUP_ROLES + SEASON_ROLES + COMMENT_ROLES +
          STATUS_ROLES + TEAM_MEMB_ROLES + PLAY_BAN_ROLES + INJURY_ROLES + TRAINING_ROLES + TRA_SCHED_ROLES +
          NOTE_ROLES + USER_ROLES
  ROLES.each do |role|
    const_set(role.upcase, role.downcase.to_sym)
  end

  validates :name, presence: true

  scope :by_group, ->(group) { joins(:groups).where(groups: { id: group }) }
  scope :asc, -> { order(name: :asc) }

  def self.create_all
    ROLES.each do |role|
      Role.find_or_create_by(name: role.downcase)
    end
  end
end
