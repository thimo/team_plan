class RenameBlankInFieldPositions < ActiveRecord::Migration[6.0]
  def change
    rename_column :field_positions, :blank, :is_blank
  end
end
