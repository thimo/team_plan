class AddGlobalToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :global, :boolean, default: true
  end
end
