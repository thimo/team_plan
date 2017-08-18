class AddActiveToClubDataCompetitions < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_competitions, :active, :boolean, default: true
  end
end
