class AddDatesToTodos < ActiveRecord::Migration[5.1]
  def change
    add_column :todos, :starts_on, :date
    add_column :todos, :ends_on, :date
  end
end
