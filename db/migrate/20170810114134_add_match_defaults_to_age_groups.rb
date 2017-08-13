class AddMatchDefaultsToAgeGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :age_groups, :players_per_team, :integer
    add_column :age_groups, :minutes_per_half, :integer
  end
end
