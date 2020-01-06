class AddMinutesPlayedToPresences < ActiveRecord::Migration[6.0]
  def change
    add_column :presences, :minutes_played, :integer
  end
end
