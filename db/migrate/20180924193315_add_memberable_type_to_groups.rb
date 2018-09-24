class AddMemberableTypeToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :memberable_via_type, :string
  end
end
