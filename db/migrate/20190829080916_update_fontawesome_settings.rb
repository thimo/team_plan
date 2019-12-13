class UpdateFontawesomeSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :tenant_settings, :fontawesome_kit_nr, :string
    remove_column :tenant_settings, :fontawesome_integrity
    remove_column :tenant_settings, :fontawesome_version
  end
end
