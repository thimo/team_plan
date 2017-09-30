class AddAfgelastToClubDataMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_matches, :afgelast, :boolean, default: false
    add_column :club_data_matches, :afgelast_status, :string
  end
end
