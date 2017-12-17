class AddActiveTeamTabToUserSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :user_settings, :active_team_tab, :string
  end
end
