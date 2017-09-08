class CreateJoinTableClubDataCompetitionClubDataTeam < ActiveRecord::Migration[5.1]
  def change
    create_join_table :club_data_competitions, :club_data_teams do |t|
      t.index [:club_data_competition_id, :club_data_team_id], name: 'competition_team'
      t.index [:club_data_team_id, :club_data_competition_id], name: 'team_competition'
    end
  end
end
