class AddDatesToYearGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :year_groups, :birthdate_from, :date
    add_column :year_groups, :birthdate_to, :date
  end
end
