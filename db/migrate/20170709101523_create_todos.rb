class CreateTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :todos do |t|
      t.references :user, foreign_key: true
      t.text :body
      t.boolean :waiting, default: false
      t.boolean :finished, default: false
      t.references :todoable, polymorphic: true

      t.timestamps
    end
  end
end
