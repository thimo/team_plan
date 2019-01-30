class MakeIndexUniquePerTenant < ActiveRecord::Migration[5.2]
  def change
    # t.index ["club_data_team_id", "competition_id"], name: "team_competition", unique: true
    remove_index :club_data_team_competitions, name: :team_competition
    add_index :club_data_team_competitions, ["tenant_id", "club_data_team_id", "competition_id"], name: :team_competition, unique: true

    # t.index ["competition_id", "club_data_team_id"], name: "competition_team", unique: true
    remove_index :club_data_team_competitions, name: :competition_team
    add_index :club_data_team_competitions, ["tenant_id", "competition_id", "club_data_team_id"], name: :competition_team, unique: true

    # t.index ["season_id", "teamcode"], name: "index_club_data_teams_on_season_id_and_teamcode", unique: true
    remove_index :club_data_teams, name: "index_club_data_teams_on_season_id_and_teamcode"
    add_index :club_data_teams, ["tenant_id", "season_id", "teamcode"], name: "index_club_data_teams_on_season_id_and_teamcode", unique: true

    # t.index ["poulecode"], name: "index_competitions_on_poulecode", unique: true
    remove_index :competitions, name: :index_competitions_on_poulecode
    add_index :competitions, ["tenant_id", "poulecode"], name: :index_competitions_on_poulecode, unique: true

    # t.index ["wedstrijdcode"], name: "index_matches_on_wedstrijdcode", unique: true
    remove_index :matches, name: :index_matches_on_wedstrijdcode
    add_index :matches, ["tenant_id", "wedstrijdcode"], name: :index_matches_on_wedstrijdcode, unique: true
  end
end
