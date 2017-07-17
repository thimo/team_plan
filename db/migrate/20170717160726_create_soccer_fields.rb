class CreateSoccerFields < ActiveRecord::Migration[5.1]
  def change
    create_table :soccer_fields do |t|
      t.string :name
      t.boolean :training
      t.boolean :match

      t.timestamps
    end
  end
end
