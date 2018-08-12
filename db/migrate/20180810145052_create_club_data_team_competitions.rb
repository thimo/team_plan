class CreateClubDataTeamCompetitions < ActiveRecord::Migration[5.2]
  def change
    rename_table :club_data_teams_competitions, :club_data_team_competitions

    add_column :club_data_team_competitions, :id, :primary_key

    # add new column but allow null values
    add_timestamps :club_data_team_competitions, null: true

    # backfill existing record with created_at and updated_at
    # values making clear that the records are faked
    long_ago = Time.zone.local(2000, 1, 1)
    ClubDataTeamCompetition.update_all(created_at: long_ago, updated_at: long_ago)

    # change not null constraints
    change_column_null :club_data_team_competitions, :created_at, false
    change_column_null :club_data_team_competitions, :updated_at, false
  end
end
