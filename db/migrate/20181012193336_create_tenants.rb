class CreateTenants < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :subdomain
      t.string :domain

      t.timestamps
    end

    Tenant.create(name: "My first tenant")
  end
end
