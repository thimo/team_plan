class CreateOrgPositionMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :org_position_members do |t|
      t.references :org_position, foreign_key: true
      t.references :member, foreign_key: true
      t.string :name
      t.date :started_on
      t.date :ended_on

      t.timestamps
    end
  end
end
