class RemoveOrgPositionTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :org_position_members
    drop_table :org_positions
  end
end
