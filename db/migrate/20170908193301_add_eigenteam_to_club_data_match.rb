class AddEigenteamToClubDataMatch < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_matches, :eigenteam, :boolean, default: false

    ClubDataMatch.all.each do |match|
      match.update_columns(eigenteam: match.teams.any?)
    end
  end
end
