class RenameClubDataCompetitionsTeamsColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :competitions_teams, :club_data_competition_id, :competition_id
  end
end
