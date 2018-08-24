class CreateJoinTableMemberUser < ActiveRecord::Migration[5.2]
  def change
    create_join_table :members, :users do |t|
      t.index [:member_id, :user_id]
      t.index [:user_id, :member_id]
    end
  end
end
