class AddStartEndDatesToTrainingSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :training_schedules, :started_on, :date
    add_column :training_schedules, :ended_on, :date
  end
end
