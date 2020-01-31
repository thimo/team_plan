class DropQueueClassicJobs < ActiveRecord::Migration[6.0]
  def change
    drop_table :queue_classic_jobs
  end
end
