class DropSoccerFieldParts < ActiveRecord::Migration[5.1]
  def change
    drop_table :soccer_field_parts
  end
end
