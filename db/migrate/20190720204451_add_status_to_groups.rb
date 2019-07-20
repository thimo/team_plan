class AddStatusToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :status, :integer, default: 1
    add_column :groups, :started_on, :date
    add_column :groups, :ended_on, :date
  end
end
