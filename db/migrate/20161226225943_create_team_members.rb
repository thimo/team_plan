class CreateTeamMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :team_members do |t|
      t.references :member, index: true, foreign_key: true
      t.references :team, index: true, foreign_key: true
      t.date :joined_on
      t.date :left_on
      t.integer :role

      t.timestamps
    end
  end
end
