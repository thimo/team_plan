class DropUserOldSettings < ActiveRecord::Migration[5.2]
  def change
    drop_table :user_old_settings
  end
end
