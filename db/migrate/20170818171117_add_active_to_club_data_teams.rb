class AddActiveToClubDataTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_teams, :active, :boolean, default: true
  end
end
