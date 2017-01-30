class AddDefaultToTeamMembers < ActiveRecord::Migration[5.0]
  def change
    change_column :team_members, :role, :integer, default: 0
  end
end
