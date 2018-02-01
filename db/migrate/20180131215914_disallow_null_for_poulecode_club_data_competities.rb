class DisallowNullForPoulecodeClubDataCompetities < ActiveRecord::Migration[5.1]
  def change
    change_column :club_data_competitions, :poulecode, :integer, null: false
  end
end
