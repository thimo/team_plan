class AddIndexToUserSettings < ActiveRecord::Migration[5.2]
  def change
    add_index :user_settings, [:user_id, :name], unique: true
  end
end
