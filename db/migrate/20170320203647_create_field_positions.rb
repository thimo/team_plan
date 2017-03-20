class CreateFieldPositions < ActiveRecord::Migration[5.1]
  def change
    create_table :field_positions do |t|
      t.string :position
      t.integer :order, default: 0
      t.boolean :indent_in_select, default: false

      t.timestamps
    end
  end
end
