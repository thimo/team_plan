class AddColumnsToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :body, :text
  end
end
