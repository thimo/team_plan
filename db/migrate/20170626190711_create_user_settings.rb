class CreateUserSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :user_settings do |t|
      t.references :user, foreign_key: true
      t.string :email_separator, default: ';'

      t.timestamps
    end
  end
end
