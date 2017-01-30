class AddImportedAtToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :imported_at, :datetime
  end
end
