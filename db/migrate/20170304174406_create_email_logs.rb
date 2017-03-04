class CreateEmailLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :email_logs do |t|
      t.string :from
      t.string :to
      t.string :subject
      t.text :body
      t.text :body_plain
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
