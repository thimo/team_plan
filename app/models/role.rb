# frozen_string_literal: true

class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles
  has_and_belongs_to_many :groups, join_table: :groups_roles

  BEHEER_ROLES = %w[beheer_applicatie beheer_vereniging beheer_knvb_club_data beheer_oefenwedstrijden
                    beheer_contributie_speelverboden].freeze
  TEAM_ROLES = %w[team_show_evaluations].freeze
  MEMBER_ROLES = %w[member_show_private_data member_show_evaluations].freeze
  ROLES = BEHEER_ROLES + TEAM_ROLES + MEMBER_ROLES
  ROLES.each do |role|
    const_set(role.upcase, role.to_sym)
  end

  validates :name, presence: true

  scope :asc, -> { order(name: :asc) }
end
