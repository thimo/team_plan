class AddAddressToClubDataMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_matches, :adres, :string
    add_column :club_data_matches, :postcode, :string
    add_column :club_data_matches, :telefoonnummer, :string
    add_column :club_data_matches, :route, :string
  end
end
