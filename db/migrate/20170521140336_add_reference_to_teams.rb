class AddReferenceToTeams < ActiveRecord::Migration[5.1]
  def change
    add_reference :teams, :club_data_teams, foreign_key: true
  end
end
