class AddParentsToFieldPositions < ActiveRecord::Migration[5.1]
  def change
    add_reference :field_positions, :line_parent, references: :field_positions, index: true
    add_foreign_key :field_positions, :field_positions, column: :line_parent_id

    add_reference :field_positions, :axis_parent, references: :field_positions, index: true
    add_foreign_key :field_positions, :field_positions, column: :axis_parent_id
  end
end
