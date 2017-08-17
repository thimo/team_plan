class RenameClubDataCompetities < ActiveRecord::Migration[5.1]
  def change
    rename_table :club_data_competities, :club_data_competitions
  end
end
