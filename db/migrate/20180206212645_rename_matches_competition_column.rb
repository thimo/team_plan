class RenameMatchesCompetitionColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :matches, :club_data_competition_id, :competition_id
  end
end
