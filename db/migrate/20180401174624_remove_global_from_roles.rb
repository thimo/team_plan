class RemoveGlobalFromRoles < ActiveRecord::Migration[5.2]
  def change
    remove_column :roles, :global
  end
end
