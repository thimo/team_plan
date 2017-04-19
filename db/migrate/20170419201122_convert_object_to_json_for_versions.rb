class ConvertObjectToJsonForVersions < ActiveRecord::Migration[5.1]
  def change
    change_column :versions, :object, 'json USING object::json'
  end
end
