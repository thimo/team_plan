# frozen_string_literal: true

class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles
  has_and_belongs_to_many :groups, join_table: :groups_roles

  validates :name, presence: true

  scope :asc, -> { order(name: :asc) }
end
