class CreateOrgPositions < ActiveRecord::Migration[5.1]
  def change
    create_table :org_positions do |t|
      t.string :name
      t.text :remark
      t.integer :position_type
      t.date :started_on
      t.date :ended_on
      t.string :ancestry

      t.timestamps
    end
    add_index :org_positions, :ancestry
  end
end
