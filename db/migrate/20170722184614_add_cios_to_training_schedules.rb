class AddCiosToTrainingSchedules < ActiveRecord::Migration[5.1]
  def change
    add_column :training_schedules, :cios, :boolean, default: false
  end
end
