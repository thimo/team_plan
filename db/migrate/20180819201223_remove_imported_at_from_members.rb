class RemoveImportedAtFromMembers < ActiveRecord::Migration[5.2]
  def change
    remove_column :members, :imported_at
  end
end
