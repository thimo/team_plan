class DefaultLocationForMatches < ActiveRecord::Migration[5.1]
  def change
    change_column :matches, :location, :integer, default: 0
  end
end
