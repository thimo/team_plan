class AddStatusToSeasons < ActiveRecord::Migration[5.0]
  def change
    remove_column :seasons, :active
    add_column :seasons, :status, :integer, default: 0
  end
end
