class CreateClubDataLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :club_data_logs do |t|
      t.integer :source
      t.integer :level
      t.string :body

      t.timestamps
    end
  end
end
