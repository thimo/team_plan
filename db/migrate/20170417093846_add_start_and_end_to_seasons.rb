class AddStartAndEndToSeasons < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :started_on, :date
    add_column :seasons, :ended_on, :date
  end
end
