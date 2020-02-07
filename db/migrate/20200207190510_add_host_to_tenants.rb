class AddHostToTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :host, :string
  end
end
