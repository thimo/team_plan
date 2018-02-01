class AddNullToPoulecodeClubDataCompetities < ActiveRecord::Migration[5.1]
  def change
    change_column :club_data_competitions, :poulecode, :integer, null: true
  end
end
