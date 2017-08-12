class CreateTrainings < ActiveRecord::Migration[5.1]
  def change
    create_table :trainings do |t|
      t.references :training_schedule, foreign_key: true
      t.boolean :active, default: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :user_modified, default: false
      t.text :body
      t.text :remark

      t.timestamps
    end
  end
end
