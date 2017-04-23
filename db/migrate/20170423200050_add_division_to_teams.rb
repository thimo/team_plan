class AddDivisionToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :division, :string
  end
end
