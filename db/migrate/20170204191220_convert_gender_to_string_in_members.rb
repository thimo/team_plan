class ConvertGenderToStringInMembers < ActiveRecord::Migration[5.0]
  def change
    change_column :members, :gender, :string
  end
end
