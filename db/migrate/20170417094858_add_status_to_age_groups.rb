class AddStatusToAgeGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :age_groups, :status, :integer
    add_column :age_groups, :started_on, :date
    add_column :age_groups, :ended_on, :date
  end
end
