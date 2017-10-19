class AddIncludeMemberCommentsToUserSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :user_settings, :include_member_comments, :boolean, default: false
  end
end
