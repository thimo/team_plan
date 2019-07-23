class RenameUserSettings < ActiveRecord::Migration[5.2]
  def change
    rename_table :user_settings, :user_old_settings
  end
end
