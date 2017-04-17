class AddDefaultToStatusToAgeGroups < ActiveRecord::Migration[5.1]
  def change
    change_column_default :age_groups, :status, 0
  end
end
