class RenamePresentInPresences < ActiveRecord::Migration[6.0]
  def change
    rename_column :presences, :present, :is_present
  end
end
