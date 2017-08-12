class AddActiveToTrainingSchedules < ActiveRecord::Migration[5.1]
  def change
    add_column :training_schedules, :active, :boolean, default: true
  end
end
