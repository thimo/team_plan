class AddEditLevelToMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :edit_level, :integer, default: 0
  end
end
