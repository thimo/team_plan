# frozen_string_literal: true

class OrgPosition < ApplicationRecord
  has_many :org_position_members
  has_ancestry

  enum position_type: { role: 0, committee: 1, working_group: 2 }

  scope :active, -> { where(ended_on: nil) }

  validates :name, :started_on, presence: true

  def self.arrange_as_array(options = {}, hash = nil)
    hash ||= arrange(options)

    arr = []
    hash.each do |node, children|
      arr << node
      arr += arrange_as_array(options, children) unless children.nil?
    end
    arr
  end

  def name_for_selects
    "#{'-' * depth} #{name}"
  end

  def possible_parents
    parents = OrgPosition.arrange_as_array(order: "name")
    new_record? ? parents : parents - subtree
  end
end
