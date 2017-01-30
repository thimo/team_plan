class AddDefaults < ActiveRecord::Migration[5.0]
  def change
    change_column :seasons, :active, :boolean, default: true
    change_column :members, :active, :boolean, default: true
  end
end
