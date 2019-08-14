class AddOwnPlayerToPresences < ActiveRecord::Migration[6.0]
  def change
    add_column :presences, :own_player, :boolean, default: true
  end
end
