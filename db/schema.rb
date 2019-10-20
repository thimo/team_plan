# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_20_183442) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"

  create_table "age_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "season_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year_of_birth_from"
    t.integer "year_of_birth_to"
    t.string "gender"
    t.integer "status", default: 0
    t.date "started_on"
    t.date "ended_on"
    t.integer "players_per_team"
    t.integer "minutes_per_half"
    t.bigint "tenant_id"
    t.index ["season_id"], name: "index_age_groups_on_season_id"
    t.index ["tenant_id"], name: "index_age_groups_on_tenant_id"
  end

  create_table "club_data_logs", force: :cascade do |t|
    t.string "source"
    t.integer "level"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["tenant_id"], name: "index_club_data_logs_on_tenant_id"
  end

  create_table "club_data_team_competitions", force: :cascade do |t|
    t.bigint "competition_id", null: false
    t.bigint "club_data_team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["tenant_id", "club_data_team_id", "competition_id"], name: "team_competition", unique: true
    t.index ["tenant_id", "competition_id", "club_data_team_id"], name: "competition_team", unique: true
    t.index ["tenant_id"], name: "index_club_data_team_competitions_on_tenant_id"
  end

  create_table "club_data_teams", force: :cascade do |t|
    t.integer "teamcode", null: false
    t.string "teamnaam"
    t.string "spelsoort"
    t.string "geslacht"
    t.string "teamsoort"
    t.string "leeftijdscategorie"
    t.string "kalespelsoort"
    t.string "speeldag"
    t.string "speeldagteam"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.bigint "season_id"
    t.bigint "tenant_id"
    t.index ["season_id"], name: "index_club_data_teams_on_season_id"
    t.index ["tenant_id", "season_id", "teamcode"], name: "index_club_data_teams_on_season_id_and_teamcode", unique: true
    t.index ["tenant_id"], name: "index_club_data_teams_on_tenant_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "body"
    t.integer "user_id"
    t.integer "comment_type", default: 0
    t.string "commentable_type"
    t.integer "commentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "private", default: false
    t.bigint "tenant_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["tenant_id"], name: "index_comments_on_tenant_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "competitions", force: :cascade do |t|
    t.integer "poulecode", null: false
    t.string "competitienaam"
    t.string "klasse"
    t.string "poule"
    t.string "klassepoule"
    t.string "competitiesoort"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.json "ranking"
    t.text "remark"
    t.boolean "user_modified", default: false
    t.bigint "tenant_id"
    t.index ["tenant_id", "poulecode"], name: "index_competitions_on_poulecode", unique: true
    t.index ["tenant_id"], name: "index_competitions_on_tenant_id"
  end

  create_table "email_logs", force: :cascade do |t|
    t.string "from"
    t.string "to"
    t.string "subject"
    t.text "body"
    t.text "body_plain"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["tenant_id"], name: "index_email_logs_on_tenant_id"
    t.index ["user_id"], name: "index_email_logs_on_user_id"
  end

  create_table "favorites", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "favorable_type"
    t.integer "favorable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["favorable_type", "favorable_id"], name: "index_favorites_on_favorable_type_and_favorable_id"
    t.index ["tenant_id"], name: "index_favorites_on_tenant_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "field_positions", force: :cascade do |t|
    t.string "name"
    t.integer "position", default: 0
    t.boolean "indent_in_select", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_blank", default: false
    t.bigint "line_parent_id"
    t.bigint "axis_parent_id"
    t.bigint "tenant_id"
    t.integer "position_type"
    t.index ["axis_parent_id"], name: "index_field_positions_on_axis_parent_id"
    t.index ["line_parent_id"], name: "index_field_positions_on_line_parent_id"
    t.index ["tenant_id"], name: "index_field_positions_on_tenant_id"
  end

  create_table "field_positions_team_members", id: false, force: :cascade do |t|
    t.bigint "field_position_id", null: false
    t.bigint "team_member_id", null: false
    t.index ["field_position_id", "team_member_id"], name: "position_member_index"
    t.index ["team_member_id", "field_position_id"], name: "member_position_index"
  end

  create_table "group_members", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memberable_type"
    t.bigint "memberable_id"
    t.bigint "tenant_id"
    t.integer "status", default: 1
    t.date "started_on"
    t.date "ended_on"
    t.string "description"
    t.index ["group_id", "member_id", "memberable_type", "memberable_id"], name: "index_group_members_unique", unique: true
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["member_id"], name: "index_group_members_on_member_id"
    t.index ["memberable_type", "memberable_id"], name: "index_group_members_on_memberable_type_and_memberable_id"
    t.index ["tenant_id"], name: "index_group_members_on_tenant_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memberable_via_type"
    t.bigint "tenant_id"
    t.integer "status", default: 1
    t.date "started_on"
    t.date "ended_on"
    t.index ["tenant_id"], name: "index_groups_on_tenant_id"
  end

  create_table "groups_roles", id: false, force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "role_id"
    t.index ["group_id", "role_id"], name: "index_groups_roles_on_group_id_and_role_id"
    t.index ["group_id"], name: "index_groups_roles_on_group_id"
    t.index ["role_id"], name: "index_groups_roles_on_role_id"
  end

  create_table "injuries", force: :cascade do |t|
    t.date "started_on"
    t.date "ended_on"
    t.string "title"
    t.text "body"
    t.bigint "user_id"
    t.bigint "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["member_id"], name: "index_injuries_on_member_id"
    t.index ["tenant_id"], name: "index_injuries_on_tenant_id"
    t.index ["user_id"], name: "index_injuries_on_user_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string "logable_type"
    t.bigint "logable_id"
    t.bigint "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["logable_type", "logable_id"], name: "index_logs_on_logable_type_and_logable_id"
    t.index ["tenant_id"], name: "index_logs_on_tenant_id"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "wedstrijddatum"
    t.integer "wedstrijdcode"
    t.integer "wedstrijdnummer"
    t.string "thuisteam"
    t.string "uitteam"
    t.string "thuisteamclubrelatiecode"
    t.string "uitteamclubrelatiecode"
    t.string "accommodatie"
    t.string "plaats"
    t.string "wedstrijd"
    t.integer "thuisteamid"
    t.integer "uitteamid"
    t.bigint "competition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "remark"
    t.boolean "user_modified", default: false
    t.string "uitslag"
    t.boolean "eigenteam", default: false
    t.datetime "uitslag_at"
    t.string "adres"
    t.string "postcode"
    t.string "telefoonnummer"
    t.string "route"
    t.boolean "afgelast", default: false
    t.string "afgelast_status"
    t.bigint "created_by_id"
    t.integer "edit_level", default: 0
    t.bigint "tenant_id"
    t.index ["competition_id"], name: "index_matches_on_competition_id"
    t.index ["created_by_id"], name: "index_matches_on_created_by_id"
    t.index ["tenant_id", "wedstrijdcode"], name: "index_matches_on_wedstrijdcode", unique: true
    t.index ["tenant_id"], name: "index_matches_on_tenant_id"
  end

  create_table "matches_teams", id: false, force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "team_id", null: false
    t.index ["match_id", "team_id"], name: "index_matches_teams_on_match_id_and_team_id", unique: true
    t.index ["team_id", "match_id"], name: "index_matches_teams_on_team_id_and_match_id", unique: true
  end

  create_table "members", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "born_on"
    t.string "address"
    t.string "zipcode"
    t.string "city"
    t.string "country"
    t.string "phone"
    t.string "phone2"
    t.string "email"
    t.string "email2"
    t.string "gender"
    t.string "member_number"
    t.string "association_number"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "email_2"
    t.string "phone_2"
    t.string "initials"
    t.string "conduct_number"
    t.string "sport_category"
    t.string "status"
    t.string "full_name_2"
    t.date "last_change_at"
    t.string "privacy_level"
    t.string "street"
    t.string "house_number"
    t.string "house_number_addition"
    t.string "phone_home"
    t.string "phone_parent"
    t.string "phone_parent_2"
    t.string "email_parent"
    t.string "email_parent_2"
    t.date "registered_at"
    t.date "deregistered_at"
    t.date "member_since"
    t.string "age_category"
    t.string "local_teams"
    t.string "club_sports"
    t.string "association_sports"
    t.string "person_type"
    t.boolean "injured", default: false
    t.string "full_name"
    t.string "photo"
    t.datetime "missed_import_on"
    t.bigint "tenant_id"
    t.index ["association_number"], name: "index_members_on_association_number"
    t.index ["tenant_id"], name: "index_members_on_tenant_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "members_users", id: false, force: :cascade do |t|
    t.bigint "member_id", null: false
    t.bigint "user_id", null: false
    t.index ["member_id", "user_id"], name: "index_members_users_on_member_id_and_user_id"
    t.index ["user_id", "member_id"], name: "index_members_users_on_user_id_and_member_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.bigint "user_id"
    t.bigint "team_id"
    t.bigint "member_id"
    t.integer "visibility", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["member_id"], name: "index_notes_on_member_id"
    t.index ["team_id"], name: "index_notes_on_team_id"
    t.index ["tenant_id"], name: "index_notes_on_tenant_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "play_bans", force: :cascade do |t|
    t.bigint "member_id"
    t.date "started_on"
    t.date "ended_on"
    t.integer "play_ban_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["member_id"], name: "index_play_bans_on_member_id"
    t.index ["tenant_id"], name: "index_play_bans_on_tenant_id"
  end

  create_table "player_evaluations", id: :serial, force: :cascade do |t|
    t.integer "team_evaluation_id"
    t.string "advise_next_season"
    t.string "behaviour"
    t.string "technique"
    t.string "handlingspeed"
    t.string "insight"
    t.string "passes"
    t.string "speed"
    t.string "locomotion"
    t.string "physical"
    t.string "endurance"
    t.string "duel_strength"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "remark"
    t.bigint "team_member_id"
    t.bigint "tenant_id"
    t.index ["team_evaluation_id"], name: "index_player_evaluations_on_team_evaluation_id"
    t.index ["team_member_id"], name: "index_player_evaluations_on_team_member_id"
    t.index ["tenant_id"], name: "index_player_evaluations_on_tenant_id"
  end

  create_table "presences", force: :cascade do |t|
    t.string "presentable_type"
    t.bigint "presentable_id"
    t.bigint "member_id"
    t.boolean "is_present", default: true
    t.integer "on_time", default: 0
    t.integer "signed_off", default: 0
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.bigint "tenant_id"
    t.boolean "own_player", default: true
    t.index ["member_id"], name: "index_presences_on_member_id"
    t.index ["presentable_type", "presentable_id"], name: "index_presences_on_presentable_type_and_presentable_id"
    t.index ["team_id"], name: "index_presences_on_team_id"
    t.index ["tenant_id"], name: "index_presences_on_tenant_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.text "body"
    t.bigint "tenant_id"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
    t.index ["tenant_id"], name: "index_roles_on_tenant_id"
  end

  create_table "seasons", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.date "started_on"
    t.date "ended_on"
    t.bigint "tenant_id"
    t.index ["tenant_id"], name: "index_seasons_on_tenant_id"
  end

  create_table "soccer_fields", force: :cascade do |t|
    t.string "name"
    t.boolean "training", default: false
    t.boolean "match", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["tenant_id"], name: "index_soccer_fields_on_tenant_id"
  end

  create_table "team_evaluation_configs", force: :cascade do |t|
    t.string "name"
    t.integer "status"
    t.jsonb "fields"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "team_evaluations", id: :serial, force: :cascade do |t|
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "invited_at"
    t.datetime "finished_at"
    t.bigint "invited_by_id"
    t.bigint "finished_by_id"
    t.boolean "private", default: false
    t.bigint "tenant_id"
    t.jsonb "fields"
    t.index ["finished_by_id"], name: "index_team_evaluations_on_finished_by_id"
    t.index ["invited_by_id"], name: "index_team_evaluations_on_invited_by_id"
    t.index ["team_id"], name: "index_team_evaluations_on_team_id"
    t.index ["tenant_id"], name: "index_team_evaluations_on_tenant_id"
  end

  create_table "team_members", id: :serial, force: :cascade do |t|
    t.integer "member_id"
    t.integer "team_id"
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prefered_foot"
    t.integer "status", default: 0
    t.date "started_on"
    t.date "ended_on"
    t.bigint "tenant_id"
    t.index ["member_id", "team_id", "role"], name: "index_team_members_on_member_id_and_team_id_and_role", unique: true
    t.index ["member_id"], name: "index_team_members_on_member_id"
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["tenant_id"], name: "index_team_members_on_tenant_id"
  end

  create_table "team_members_training_schedules", id: false, force: :cascade do |t|
    t.bigint "team_member_id", null: false
    t.bigint "training_schedule_id", null: false
    t.index ["team_member_id", "training_schedule_id"], name: "member_schedule"
    t.index ["training_schedule_id", "team_member_id"], name: "schedule_member"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "age_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.date "started_on"
    t.date "ended_on"
    t.string "division"
    t.text "remark"
    t.integer "players_per_team"
    t.integer "minutes_per_half"
    t.bigint "club_data_team_id"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.bigint "tenant_id"
    t.index ["age_group_id"], name: "index_teams_on_age_group_id"
    t.index ["club_data_team_id"], name: "index_teams_on_club_data_team_id"
    t.index ["tenant_id"], name: "index_teams_on_tenant_id"
    t.index ["uuid"], name: "index_teams_on_uuid"
  end

  create_table "tenant_settings", force: :cascade do |t|
    t.bigint "tenant_id"
    t.string "application_name", default: "TeamPlan"
    t.string "application_hostname", default: "teamplan.defrog.nl"
    t.string "application_email", default: "helpdesk@defrog.nl"
    t.string "application_contact_name", default: "Thimo Jansen"
    t.boolean "application_maintenance", default: false
    t.string "application_favicon_url", default: "/favicon.ico"
    t.string "application_sysadmin_email", default: "thimo@teamplanpro.nl"
    t.string "club_name", default: "Defrog"
    t.string "club_name_short", default: "Defrog"
    t.string "club_website", default: "https://teamplan.defrog.nl/"
    t.string "club_sportscenter"
    t.string "club_address"
    t.string "club_zip"
    t.string "club_city"
    t.string "club_phone"
    t.string "club_relatiecode"
    t.string "club_logo_url"
    t.string "club_member_administration_email"
    t.string "clubdata_urls_competities", default: "https://data.sportlink.com/teams?teamsoort=bond&spelsoort=ve&gebruiklokaleteamgegevens=NEE"
    t.string "clubdata_urls_poulestand", default: "https://data.sportlink.com/poulestand?gebruiklokaleteamgegevens=NEE"
    t.string "clubdata_urls_poule_programma", default: "https://data.sportlink.com/poule-programma?eigenwedstrijden=NEE&gebruiklokaleteamgegevens=NEE&aantaldagen=365&weekoffset=-2"
    t.string "clubdata_urls_pouleuitslagen", default: "https://data.sportlink.com/pouleuitslagen?eigenwedstrijden=NEE&gebruiklokaleteamgegevens=NEE&aantaldagen=30&weekoffset=-4&"
    t.string "clubdata_urls_uitslagen", default: "https://data.sportlink.com/uitslagen?aantalregels=300&gebruiklokaleteamgegevens=NEE&sorteervolgorde=datum-omgekeerd&thuis=JA&uit=JA"
    t.string "clubdata_urls_team_indeling", default: "https://data.sportlink.com/team-indeling?lokaleteamcode=-1&teampersoonrol=ALLES&toonlidfoto=JA"
    t.string "clubdata_urls_wedstrijd_accommodatie", default: "https://data.sportlink.com/wedstrijd-accommodatie"
    t.string "clubdata_urls_afgelastingen", default: "https://data.sportlink.com/afgelastingen?aantalregels=100&weekoffset=-1"
    t.string "clubdata_urls_club_logos", default: "http://bin617.website-voetbal.nl/sites/voetbal.nl/files/knvblogos/"
    t.string "clubdata_client_id"
    t.string "google_maps_base_url", default: "https://www.google.com/maps/embed/v1/"
    t.string "google_maps_api_key"
    t.string "google_analytics_tracking_id"
    t.string "sportlink_members_encoding", default: "utf-8"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_import_members"
    t.string "fontawesome_kit_nr"
    t.index ["tenant_id"], name: "index_tenant_settings_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 1
  end

  create_table "todos", force: :cascade do |t|
    t.bigint "user_id"
    t.text "body"
    t.boolean "waiting", default: false
    t.boolean "finished", default: false
    t.string "todoable_type"
    t.bigint "todoable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "started_on"
    t.date "ended_on"
    t.bigint "tenant_id"
    t.index ["tenant_id"], name: "index_todos_on_tenant_id"
    t.index ["todoable_type", "todoable_id"], name: "index_todos_on_todoable_type_and_todoable_id"
    t.index ["user_id"], name: "index_todos_on_user_id"
  end

  create_table "training_schedules", force: :cascade do |t|
    t.integer "day"
    t.time "start_time"
    t.time "end_time"
    t.integer "field_part"
    t.bigint "soccer_field_id"
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cios", default: false
    t.boolean "active", default: true
    t.integer "present_minutes", default: 0
    t.bigint "tenant_id"
    t.date "started_on"
    t.date "ended_on"
    t.index ["soccer_field_id"], name: "index_training_schedules_on_soccer_field_id"
    t.index ["team_id"], name: "index_training_schedules_on_team_id"
    t.index ["tenant_id"], name: "index_training_schedules_on_tenant_id"
  end

  create_table "trainings", force: :cascade do |t|
    t.bigint "training_schedule_id"
    t.boolean "active", default: true
    t.datetime "started_at"
    t.datetime "ended_at"
    t.boolean "user_modified", default: false
    t.text "body"
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.bigint "tenant_id"
    t.index ["team_id"], name: "index_trainings_on_team_id"
    t.index ["tenant_id"], name: "index_trainings_on_tenant_id"
    t.index ["training_schedule_id"], name: "index_trainings_on_training_schedule_id"
  end

  create_table "user_settings", force: :cascade do |t|
    t.bigint "tenant_id"
    t.bigint "user_id"
    t.string "name"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_user_settings_on_tenant_id"
    t.index ["user_id", "name"], name: "index_user_settings_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.integer "status", default: 1
    t.bigint "tenant_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id", "email"], name: "index_users_on_tenant_id_and_email", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
    t.index ["uuid"], name: "index_users_on_uuid"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "version_updates", force: :cascade do |t|
    t.datetime "released_at"
    t.string "name"
    t.text "body"
    t.integer "for_role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "age_groups", "seasons"
  add_foreign_key "age_groups", "tenants"
  add_foreign_key "club_data_logs", "tenants"
  add_foreign_key "club_data_team_competitions", "tenants"
  add_foreign_key "club_data_teams", "seasons"
  add_foreign_key "club_data_teams", "tenants"
  add_foreign_key "comments", "tenants"
  add_foreign_key "comments", "users"
  add_foreign_key "competitions", "tenants"
  add_foreign_key "email_logs", "tenants"
  add_foreign_key "email_logs", "users"
  add_foreign_key "favorites", "tenants"
  add_foreign_key "favorites", "users"
  add_foreign_key "field_positions", "field_positions", column: "axis_parent_id"
  add_foreign_key "field_positions", "field_positions", column: "line_parent_id"
  add_foreign_key "field_positions", "tenants"
  add_foreign_key "group_members", "groups"
  add_foreign_key "group_members", "members"
  add_foreign_key "group_members", "tenants"
  add_foreign_key "groups", "tenants"
  add_foreign_key "injuries", "members"
  add_foreign_key "injuries", "tenants"
  add_foreign_key "injuries", "users"
  add_foreign_key "logs", "tenants"
  add_foreign_key "logs", "users"
  add_foreign_key "matches", "competitions"
  add_foreign_key "matches", "tenants"
  add_foreign_key "matches", "users", column: "created_by_id"
  add_foreign_key "members", "tenants"
  add_foreign_key "members", "users"
  add_foreign_key "notes", "members"
  add_foreign_key "notes", "teams"
  add_foreign_key "notes", "tenants"
  add_foreign_key "notes", "users"
  add_foreign_key "play_bans", "members"
  add_foreign_key "play_bans", "tenants"
  add_foreign_key "player_evaluations", "team_evaluations"
  add_foreign_key "player_evaluations", "team_members"
  add_foreign_key "player_evaluations", "tenants"
  add_foreign_key "presences", "members"
  add_foreign_key "presences", "teams"
  add_foreign_key "presences", "tenants"
  add_foreign_key "roles", "tenants"
  add_foreign_key "seasons", "tenants"
  add_foreign_key "soccer_fields", "tenants"
  add_foreign_key "team_evaluations", "teams"
  add_foreign_key "team_evaluations", "tenants"
  add_foreign_key "team_evaluations", "users", column: "finished_by_id"
  add_foreign_key "team_evaluations", "users", column: "invited_by_id"
  add_foreign_key "team_members", "members"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "tenants"
  add_foreign_key "teams", "age_groups"
  add_foreign_key "teams", "club_data_teams"
  add_foreign_key "teams", "tenants"
  add_foreign_key "tenant_settings", "tenants"
  add_foreign_key "todos", "tenants"
  add_foreign_key "todos", "users"
  add_foreign_key "training_schedules", "soccer_fields"
  add_foreign_key "training_schedules", "teams"
  add_foreign_key "training_schedules", "tenants"
  add_foreign_key "trainings", "teams"
  add_foreign_key "trainings", "tenants"
  add_foreign_key "trainings", "training_schedules"
  add_foreign_key "user_settings", "tenants"
  add_foreign_key "user_settings", "users"
  add_foreign_key "users", "tenants"
end
