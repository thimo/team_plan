class UniqueWedstrijdcodeForClubDataMatches < ActiveRecord::Migration[5.1]
  def change
    add_index :club_data_matches, :wedstrijdcode, unique: true
  end
end
