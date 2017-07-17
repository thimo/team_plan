class CreateTrainingSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :training_schedules do |t|
      t.integer :day
      t.time :present_time
      t.time :start_time
      t.time :end_time
      t.integer :field_part
      t.references :soccer_field, foreign_key: true
      t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
