class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.string :title
      t.text :body
      t.references :user, foreign_key: true
      t.references :team, foreign_key: true
      t.references :member, foreign_key: true
      t.integer :visibility

      t.timestamps
    end
  end
end
