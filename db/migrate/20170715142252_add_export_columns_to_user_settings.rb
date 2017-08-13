class AddExportColumnsToUserSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :user_settings, :export_columns, :string, array: true, default: []
  end
end
