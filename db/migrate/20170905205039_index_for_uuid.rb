class IndexForUuid < ActiveRecord::Migration[5.1]
  def change
    add_index(:teams, :uuid)
    add_index(:users, :uuid)
  end
end
