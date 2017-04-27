class CreateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :logs do |t|
      t.references :logable, polymorphic: true
      t.references :user, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
