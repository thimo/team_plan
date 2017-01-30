class DefaultFalseForActiveToSeasons < ActiveRecord::Migration[5.0]
  def change
    change_column :seasons, :active, :boolean, default: false
  end
end
