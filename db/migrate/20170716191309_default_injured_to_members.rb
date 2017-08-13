class DefaultInjuredToMembers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :members, :injured, false
  end
end
