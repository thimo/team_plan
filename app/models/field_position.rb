# == Schema Information
#
# Table name: field_positions
#
#  id               :bigint           not null, primary key
#  indent_in_select :boolean          default(FALSE)
#  is_blank         :boolean          default(FALSE)
#  name             :string
#  position         :integer          default(0)
#  position_type    :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  axis_parent_id   :bigint
#  line_parent_id   :bigint
#  tenant_id        :bigint
#
# Indexes
#
#  index_field_positions_on_axis_parent_id  (axis_parent_id)
#  index_field_positions_on_line_parent_id  (line_parent_id)
#  index_field_positions_on_tenant_id       (tenant_id)
#

# Player positions on the soccer field
class FieldPosition < ApplicationRecord
  has_and_belongs_to_many :team_members

  acts_as_tenant :tenant
  belongs_to :line_parent, class_name: "FieldPosition"
  belongs_to :axis_parent, class_name: "FieldPosition"
  has_many :line_children, foreign_key: :line_parent_id, class_name: "FieldPosition", dependent: :destroy
  has_many :axis_children, foreign_key: :axis_parent_id, class_name: "FieldPosition", dependent: :destroy
  has_paper_trail

  enum position_type: {goalkeeper: 0, defender: 1, midfielder: 2, forward: 3}

  default_scope { order(position: :asc) }

  def top_line_parent
    return self if line_parent.blank?

    line_parent.top_line_parent
  end

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
