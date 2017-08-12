class CreatePresences < ActiveRecord::Migration[5.1]
  def change
    create_table :presences do |t|
      t.references :presentable, polymorphic: true
      t.references :member, foreign_key: true
      t.boolean :present, default: true
      t.integer :on_time, default: 0
      t.integer :signed_off, default: 0
      t.text :remark

      t.timestamps
    end
  end
end
