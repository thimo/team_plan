class CreateSoccerFieldParts < ActiveRecord::Migration[5.1]
  def change
    create_table :soccer_field_parts do |t|
      t.string :name
      t.references :soccer_field, foreign_key: true

      t.timestamps
    end
  end
end
