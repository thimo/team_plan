class RemoveTeamFromClubDataCompetition < ActiveRecord::Migration[5.1]
  def change
    remove_column :club_data_competitions, :club_data_team_id
  end
end
