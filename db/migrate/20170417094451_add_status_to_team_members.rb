class AddStatusToTeamMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :team_members, :status, :integer, default: 0
    add_column :team_members, :started_on, :date
    add_column :team_members, :ended_on, :date
  end
end
