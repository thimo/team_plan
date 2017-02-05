class AddUniqueIndexToTeamMembers < ActiveRecord::Migration[5.0]
  def change
    add_index :team_members, [:member_id, :team_id, :role], unique: true
  end
end
