class RenameBirthdaysInYearGroups < ActiveRecord::Migration[5.0]
  def change
    remove_column :year_groups, :birthdate_from
    remove_column :year_groups, :birthdate_to

    add_column :year_groups, :year_of_birth_from, :integer
    add_column :year_groups, :year_of_birth_to, :integer
  end
end
