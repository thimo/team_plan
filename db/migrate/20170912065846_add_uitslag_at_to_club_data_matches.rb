class AddUitslagAtToClubDataMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_matches, :uitslag_at, :datetime
  end
end
