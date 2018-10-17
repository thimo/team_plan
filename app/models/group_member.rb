# frozen_string_literal: true

# Links members to groups
class GroupMember < ApplicationRecord
  multi_tenant :tenant
  belongs_to :group
  belongs_to :member
  belongs_to :memberable, polymorphic: true, optional: true

  validates :member, uniqueness: { scope: [:group, :memberable_type, :memberable_id] }
end
