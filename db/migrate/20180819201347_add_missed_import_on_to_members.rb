class AddMissedImportOnToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :missed_import_on, :datetime
  end
end
