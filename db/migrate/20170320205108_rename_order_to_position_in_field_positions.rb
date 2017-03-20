class RenameOrderToPositionInFieldPositions < ActiveRecord::Migration[5.1]
  def change
    rename_column :field_positions, :position, :name
    rename_column :field_positions, :order, :position
  end
end
