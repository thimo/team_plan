# frozen_string_literal: true

# Links members to groups
class GroupMember < ApplicationRecord
  include Statussable

  acts_as_tenant :tenant
  belongs_to :group
  belongs_to :member
  belongs_to :memberable, polymorphic: true, optional: true

  scope :by_group, ->(group) { where(group: group) }

  validates :member, uniqueness: { scope: [:tenant, :group, :memberable_type, :memberable_id] }
end
