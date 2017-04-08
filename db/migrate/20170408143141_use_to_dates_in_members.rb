class UseToDatesInMembers < ActiveRecord::Migration[5.1]
  def change
    change_column :members, :registered_at, 'date USING registered_at::date'
    change_column :members, :deregistered_at, 'date USING deregistered_at::date'
    change_column :members, :member_since, 'date USING member_since::date'
    rename_column :members, :lasts_change_at, :last_change_at
    change_column :members, :last_change_at, 'date USING last_change_at::date'
  end
end
