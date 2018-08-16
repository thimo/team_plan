# frozen_string_literal: true

class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles
  has_and_belongs_to_many :groups, join_table: :groups_roles

  validates :name, presence: true

  # TODO: list possible roles in a const array

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  scope :with_no_resource, -> { where(resource: nil) }
  scope :asc, -> { order(name: :asc) }
end
