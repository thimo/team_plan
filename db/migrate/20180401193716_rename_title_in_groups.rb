class RenameTitleInGroups < ActiveRecord::Migration[5.2]
  def change
    rename_column :groups, :title, :name
  end
end
