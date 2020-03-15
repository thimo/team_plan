class AddLocalTeamsToTenantSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :tenant_settings, :local_teams_always_allowed_in_team, :string, array: true, default: []
    add_column :tenant_settings, :local_teams_warning_sportlink, :string, array: true, default: []
  end
end
