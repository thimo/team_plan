class AddTimestampsToUserSettings < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :user_settings
  end
end
