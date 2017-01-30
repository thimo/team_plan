class AddColumnsToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :email_2, :string
    add_column :members, :phone_2, :string
    add_column :members, :initials, :string
    add_column :members, :conduct_number, :string
    add_column :members, :sport_category, :string
    rename_column :members, :member_id, :member_number
    rename_column :members, :association_id, :association_number
  end
end
