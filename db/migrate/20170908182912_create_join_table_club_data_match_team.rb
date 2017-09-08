class CreateJoinTableClubDataMatchTeam < ActiveRecord::Migration[5.1]
  def change
    create_join_table :club_data_matches, :teams do |t|
      t.index [:club_data_match_id, :team_id], unique: true
      t.index [:team_id, :club_data_match_id], unique: true
    end
  end
end
