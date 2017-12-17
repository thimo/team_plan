class SetPrivateDefaultFalse < ActiveRecord::Migration[5.1]
  def change
    change_column_default :team_evaluations, :private, false
  end
end
