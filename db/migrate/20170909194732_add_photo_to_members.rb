class AddPhotoToMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :photo, :string
  end
end
