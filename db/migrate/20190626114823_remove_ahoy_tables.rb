class RemoveAhoyTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :ahoy_events
    drop_table :ahoy_visits
  end
end
