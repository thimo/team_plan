class AddEndsAtToMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :ends_at, :datetime
  end
end
