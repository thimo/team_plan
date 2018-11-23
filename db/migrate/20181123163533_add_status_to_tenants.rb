class AddStatusToTenants < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants, :status, :integer, default: 1
  end
end
