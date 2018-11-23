# frozen_string_literal: true

class Group < ApplicationRecord
  acts_as_tenant :tenant
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members
  has_and_belongs_to_many :roles

  validates :name, presence: true

  scope :by_model, ->(model) { where(memberable_via_type: model) }
  scope :asc, -> { order(name: :asc) }
  scope :for_member, ->(member) { joins(:group_members).where(group_members: { member: member }) }
  scope :for_memberable, ->(type, id) {
    joins(:group_members).where(group_members: { memberable_type: type, memberable_id: id })
  }

  MEMBERABLE_VIA_TYPES = %w[AgeGroup].freeze
end
