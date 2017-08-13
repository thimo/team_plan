class CreateMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :matches do |t|
      t.boolean :active, default: true
      t.datetime :started_at
      t.boolean :user_modified, default: false
      t.text :body
      t.text :remark
      t.references :team, foreign_key: true
      t.string :opponent
      t.boolean :home_match, default: true
      t.integer :goals_self, default: 0
      t.integer :goals_opponent, default: 0

      t.timestamps
    end
  end
end
