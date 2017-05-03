class AddRemarkToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :remark, :text
  end
end
