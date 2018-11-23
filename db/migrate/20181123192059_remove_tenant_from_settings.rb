class RemoveTenantFromSettings < ActiveRecord::Migration[5.2]
  def change
    remove_column :settings, :tenant_id
  end
end
