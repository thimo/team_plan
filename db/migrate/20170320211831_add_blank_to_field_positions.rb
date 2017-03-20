class AddBlankToFieldPositions < ActiveRecord::Migration[5.1]
  def change
    add_column :field_positions, :blank, :boolean, default: false
  end
end
