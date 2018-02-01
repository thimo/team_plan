class DefaultForPositionTypeInOrgPosition < ActiveRecord::Migration[5.1]
  def change
    change_column_default :org_positions, :position_type, 0
  end
end
