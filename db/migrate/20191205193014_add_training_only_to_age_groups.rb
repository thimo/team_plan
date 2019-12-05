class AddTrainingOnlyToAgeGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :age_groups, :training_only, :boolean, default: false
  end
end
