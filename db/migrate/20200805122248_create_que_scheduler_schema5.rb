class CreateQueSchedulerSchema5 < ActiveRecord::Migration[6.0]
  def change
    create_table :que_scheduler_schema5s do |t|
      Que::Scheduler::Migrations.migrate!(version: 5)
    end
  end
end
