class AddInjuredToMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :injured, :boolean
  end
end
