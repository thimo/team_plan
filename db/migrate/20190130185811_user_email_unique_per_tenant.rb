class UserEmailUniquePerTenant < ActiveRecord::Migration[5.2]
  def change
    remove_index :users, :email
    add_index :users, [:tenant_id, :email], unique: true
  end
end
