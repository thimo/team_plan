class AddFieldsToClubDataMatch < ActiveRecord::Migration[5.1]
  def change
    add_column :club_data_matches, :remark, :text
    add_column :club_data_matches, :user_modified, :boolean, default: false
  end
end
