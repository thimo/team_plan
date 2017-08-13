class DefaultsForSoccerFields < ActiveRecord::Migration[5.1]
  def change
    change_column_default :soccer_fields, :training, false
    change_column_default :soccer_fields, :match, true
  end
end
