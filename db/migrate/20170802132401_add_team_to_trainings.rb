class AddTeamToTrainings < ActiveRecord::Migration[5.1]
  def change
    add_reference :trainings, :team, foreign_key: true
  end
end
