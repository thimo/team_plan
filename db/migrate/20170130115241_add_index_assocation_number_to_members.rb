class AddIndexAssocationNumberToMembers < ActiveRecord::Migration[5.0]
  def change
    add_index :members, :association_number
  end
end
