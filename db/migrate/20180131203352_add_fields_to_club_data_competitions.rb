class AddFieldsToClubDataCompetitions < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_competitions, :remark, :text
    add_column :club_data_competitions, :user_modified, :boolean, default: false
  end
end
