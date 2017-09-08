class RemoveTeamFromClubDataMatch < ActiveRecord::Migration[5.1]
  def change
    ClubDataMatch.where.not(team: nil).each do |match|
      match.teams << match.team
    end

    remove_column :club_data_matches, :team_id
  end
end
