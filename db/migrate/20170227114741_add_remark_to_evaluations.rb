class AddRemarkToEvaluations < ActiveRecord::Migration[5.1]
  def change
    add_column :evaluations, :remark, :text
  end
end
