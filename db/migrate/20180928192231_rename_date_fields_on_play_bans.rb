class RenameDateFieldsOnPlayBans < ActiveRecord::Migration[5.2]
  def change
    rename_column :play_bans, :starts_at, :started_on
    rename_column :play_bans, :ends_at, :ended_on
  end
end
