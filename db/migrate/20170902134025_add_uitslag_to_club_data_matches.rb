class AddUitslagToClubDataMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_matches, :uitslag, :string
  end
end
