class CreateQueScheduler < ActiveRecord::Migration[6.1]
  def change
    Que::Scheduler::Migrations.migrate!(version: 6)
  end
end
