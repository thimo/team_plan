class AddGenderToYearGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :year_groups, :gender, :string
  end
end
