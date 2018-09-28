class CreatePlayBans < ActiveRecord::Migration[5.2]
  def change
    create_table :play_bans do |t|
      t.references :member, foreign_key: true
      t.date :starts_at
      t.date :ends_at
      t.integer :play_ban_type
      t.text :body

      t.timestamps
    end
  end
end
