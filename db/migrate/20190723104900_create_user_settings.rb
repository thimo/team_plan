class CreateUserSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_settings do |t|
      t.references :tenant, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name
      t.text :value
    end
  end
end
