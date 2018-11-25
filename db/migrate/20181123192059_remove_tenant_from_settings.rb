class RemoveTenantFromSettings < ActiveRecord::Migration[5.2]
  def change
    remove_column :settings, :tenant_id

    Setting.update_all(thing_type: Tenant.to_s, thing_id: Tenant.first.id)
  end
end
