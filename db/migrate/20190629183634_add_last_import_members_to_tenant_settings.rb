class AddLastImportMembersToTenantSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :tenant_settings, :last_import_members, :datetime
  end
end
