class AddMatchDefaultsToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :players_per_team, :integer
    add_column :teams, :minutes_per_half, :integer
  end
end
