# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members
  has_and_belongs_to_many :roles

  validates :name, presence: true

  scope :asc, -> { order(name: :asc) }

  MEMBERABLE_VIA_TYPES = %w[AgeGroup].freeze
end
