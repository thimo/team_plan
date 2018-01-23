class ChangeSourceToStringInClubDataLogs < ActiveRecord::Migration[5.1]
  def change
    change_column :club_data_logs, :source, :string
  end
end
