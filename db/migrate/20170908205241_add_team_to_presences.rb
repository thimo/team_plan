class AddTeamToPresences < ActiveRecord::Migration[5.1]
  def change
    add_reference :presences, :team, foreign_key: true
  end
end
