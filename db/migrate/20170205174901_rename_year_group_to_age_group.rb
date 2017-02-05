class RenameYearGroupToAgeGroup < ActiveRecord::Migration[5.0]
  def change
    rename_table :year_groups, :age_groups
    rename_column :teams, :year_group_id, :age_group_id
  end
end
