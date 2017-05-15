class RemoveDatesFromTeamMembers < ActiveRecord::Migration[5.1]
  def change
    remove_column :team_members, :joined_on
    remove_column :team_members, :left_on
  end
end
