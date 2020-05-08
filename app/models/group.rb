# == Schema Information
#
# Table name: groups
#
#  id                  :bigint           not null, primary key
#  ended_on            :date
#  memberable_via_type :string
#  name                :string
#  started_on          :date
#  status              :integer          default("active")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  tenant_id           :bigint
#
# Indexes
#
#  index_groups_on_tenant_id  (tenant_id)
#

# User groups give users roles
class Group < ApplicationRecord
  include Statussable

  acts_as_tenant :tenant
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members
  has_and_belongs_to_many :roles

  validates :name, presence: true

  scope :by_model, ->(model) { where(memberable_via_type: model) }
  scope :asc, -> { order(name: :asc) }
  scope :for_member, ->(member) { joins(:group_members).where(group_members: {member: member}) }
  scope :for_memberable, ->(type, id) {
    joins(:group_members).where(group_members: {memberable_type: type, memberable_id: id})
  }
  scope :via_type, -> { where.not(memberable_via_type: [nil, ""]) }

  MEMBERABLE_VIA_TYPES = %w[AgeGroup Team].freeze
end
