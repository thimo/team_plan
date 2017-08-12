class RenameStartsEnds < ActiveRecord::Migration[5.1]
  def change
    rename_column :todos, :starts_on, :started_on
    rename_column :todos, :ends_on, :ended_on
    rename_column :trainings, :starts_at, :started_at
    rename_column :trainings, :ends_at, :ended_at
  end
end
