class AddFieldsToTeamMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :team_members, :field_position, :string
    add_column :team_members, :prefered_foot, :string
  end
end
