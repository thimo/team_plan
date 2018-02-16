class AddUserToMatches < ActiveRecord::Migration[5.2]
  def change
    add_reference :matches, :created_by, references: :users, index: true
    add_foreign_key :matches, :users, column: :created_by_id
  end
end
