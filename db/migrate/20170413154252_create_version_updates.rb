class CreateVersionUpdates < ActiveRecord::Migration[5.1]
  def change
    create_table :version_updates do |t|
      t.datetime :released_at
      t.string :name
      t.text :body
      t.integer :for_role, default: 0

      t.timestamps
    end
  end
end
