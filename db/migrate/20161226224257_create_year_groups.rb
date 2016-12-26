class CreateYearGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :year_groups do |t|
      t.string :name
      t.references :season, index: true, foreign_key: true

      t.timestamps
    end
  end
end
