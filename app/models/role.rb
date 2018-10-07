# frozen_string_literal: true

class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles
  has_and_belongs_to_many :groups, join_table: :groups_roles

  BEHEER_ROLES = %w[BEHEER_APPLICATIE BEHEER_VERENIGING BEHEER_KNVB_CLUB_DATA BEHEER_OEFENWEDSTRIJDEN
                    BEHEER_CONTRIBUTIE_SPEELVERBODEN].freeze
  MEMBER_ROLES = %w[MEMBER_SHOW_PRIVATE_DATA MEMBER_PREVIOUS_TEAM MEMBER_SHOW_EVALUATIONS
                    MEMBER_SHOW_FULL_BORN_ON].freeze
  TEAM_ROLES = %w[TEAM_SHOW_EVALUATIONS TEAM_SHOW_COMMENTS TEAM_SHOW_NOTES TEAM_SHOW_STATISTICS].freeze
  AGE_GROUP_ROLES = %w[].freeze
  SEASON_ROLES = %w[].freeze
  COMMENT_ROLES = %w[COMMENT_CREATE COMMENT_GENERIC COMMENT_TECHNIQUE COMMENT_BEHAVIOUR COMMENT_CLASSIFICATION
                     COMMENT_MEMBERSHIP].freeze
  GENERIC_ROLES = %w[STATUS_DRAFT].freeze

  ROLES = BEHEER_ROLES + TEAM_ROLES + MEMBER_ROLES + AGE_GROUP_ROLES + SEASON_ROLES + COMMENT_ROLES + GENERIC_ROLES
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
