class AddFullNameToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :full_name, :string
  end
end
