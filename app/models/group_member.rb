# == Schema Information
#
# Table name: group_members
#
#  id              :bigint           not null, primary key
#  description     :string
#  ended_on        :date
#  memberable_type :string
#  started_on      :date
#  status          :integer          default("active")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  group_id        :bigint
#  member_id       :bigint
#  memberable_id   :bigint
#  tenant_id       :bigint
#
# Indexes
#
#  index_group_members_on_group_id                           (group_id)
#  index_group_members_on_member_id                          (member_id)
#  index_group_members_on_memberable_type_and_memberable_id  (memberable_type,memberable_id)
#  index_group_members_on_tenant_id                          (tenant_id)
#  index_group_members_unique                                (group_id,member_id,memberable_type,memberable_id) UNIQUE
#

# Links members to groups
class GroupMember < ApplicationRecord
  include Statussable

  acts_as_tenant :tenant
  belongs_to :group
  belongs_to :member
  belongs_to :memberable, polymorphic: true, optional: true

  scope :by_group, ->(group) { where(group: group) }

  validates :member, uniqueness: {scope: [:tenant, :group, :memberable_type, :memberable_id]}
end
