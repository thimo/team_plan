class AddRankingToClubDataCompetitions < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_competitions, :ranking, :json
  end
end
