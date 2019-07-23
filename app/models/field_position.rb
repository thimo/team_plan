# frozen_string_literal: true

class FieldPosition < ApplicationRecord
  has_and_belongs_to_many :team_members

  acts_as_tenant :tenant
  belongs_to :line_parent, class_name: "FieldPosition"
  belongs_to :axis_parent, class_name: "FieldPosition"
  has_many :line_children, foreign_key: :line_parent_id, class_name: "FieldPosition", dependent: :destroy
  has_many :axis_children, foreign_key: :axis_parent_id, class_name: "FieldPosition", dependent: :destroy
  has_paper_trail

  default_scope { order(position: :asc) }

  def self.options_for_select
    all.collect do |pos|
      name = pos.name.to_s
      # Hide blank field positions for now
      if pos.present?
        id = pos.blank? ? "" : pos.id
        [name, id]
      end
    end
  end
end
