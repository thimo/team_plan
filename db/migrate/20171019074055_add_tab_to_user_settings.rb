class AddTabToUserSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :user_settings, :active_comments_tab, :string
  end
end
