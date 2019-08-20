class AddTypeToFieldPositions < ActiveRecord::Migration[6.0]
  def change
    add_column :field_positions, :position_type, :integer
  end
end
