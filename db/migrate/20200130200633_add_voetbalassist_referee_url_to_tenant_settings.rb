class AddVoetbalassistRefereeUrlToTenantSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :tenant_settings, :voetbalassist_referee_url, :string
  end
end
