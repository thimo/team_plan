class CreateGroupMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :group_members do |t|
      t.references :group, foreign_key: true
      t.references :member, foreign_key: true

      t.timestamps
    end
  end
end
