class RenameClubDataMatches < ActiveRecord::Migration[5.1]
  def change
    rename_table :club_data_matches, :matches
  end
end
