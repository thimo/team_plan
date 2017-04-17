class AddStatusToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :status, :integer, default: 0
    add_column :teams, :started_on, :date
    add_column :teams, :ended_on, :date
  end
end
