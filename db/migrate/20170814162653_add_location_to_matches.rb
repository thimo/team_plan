class AddLocationToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :location, :integer
    remove_column :matches, :home_match
  end
end
