class ConvertPresentTimeInTrainingSchedules < ActiveRecord::Migration[5.1]
  def change
    add_column :training_schedules, :present_minutes, :integer, default: 0
    remove_column :training_schedules, :present_time
  end
end
