class RenameClubDataCompetitions < ActiveRecord::Migration[5.1]
  def change
    rename_table :club_data_competitions, :competitions
  end
end
