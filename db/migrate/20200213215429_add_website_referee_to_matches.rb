class AddWebsiteRefereeToMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :website_referee, :string
  end
end
