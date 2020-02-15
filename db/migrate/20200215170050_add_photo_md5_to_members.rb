class AddPhotoMd5ToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :photo_md5, :string
  end
end
