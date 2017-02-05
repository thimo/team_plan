# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170205100942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "user_id"
    t.integer  "comment_type",     default: 0
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "private",          default: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "members", force: :cascade do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.date     "born_on"
    t.string   "address"
    t.string   "zipcode"
    t.string   "city"
    t.string   "country"
    t.string   "phone"
    t.string   "phone2"
    t.string   "email"
    t.string   "email2"
    t.string   "gender"
    t.string   "member_number"
    t.string   "association_number"
    t.boolean  "active",                default: true
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "user_id"
    t.string   "email_2"
    t.string   "phone_2"
    t.string   "initials"
    t.string   "conduct_number"
    t.string   "sport_category"
    t.datetime "imported_at"
    t.string   "status"
    t.string   "full_name_2"
    t.string   "place_of_birth"
    t.string   "country_of_birth"
    t.string   "nationality"
    t.string   "nationality_2"
    t.string   "id_type"
    t.string   "id_number"
    t.date     "lasts_change_at"
    t.string   "privacy_level"
    t.string   "street"
    t.string   "house_number"
    t.string   "house_number_addition"
    t.string   "phone_home"
    t.string   "contact_via_parent"
    t.string   "phone_parent"
    t.string   "phone_parent_2"
    t.string   "email_parent"
    t.string   "email_parent_2"
    t.string   "bank_account_type"
    t.string   "bank_account_number"
    t.string   "bank_bic"
    t.string   "bank_authorization"
    t.string   "contribution_category"
    t.string   "registered_at"
    t.string   "deregistered_at"
    t.string   "member_since"
    t.string   "age_category"
    t.string   "local_teams"
    t.string   "club_sports"
    t.string   "association_sports"
    t.index ["association_number"], name: "index_members_on_association_number", using: :btree
    t.index ["user_id"], name: "index_members_on_user_id", using: :btree
  end

  create_table "seasons", force: :cascade do |t|
    t.string   "name"
    t.boolean  "active",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "team_members", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "team_id"
    t.date     "joined_on"
    t.date     "left_on"
    t.integer  "role",       default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["member_id"], name: "index_team_members_on_member_id", using: :btree
    t.index ["team_id"], name: "index_team_members_on_team_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "year_group_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["year_group_id"], name: "index_teams_on_year_group_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "role",                   default: 0
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "year_groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "season_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "year_of_birth_from"
    t.integer  "year_of_birth_to"
    t.string   "gender"
    t.index ["season_id"], name: "index_year_groups_on_season_id", using: :btree
  end

  add_foreign_key "comments", "users"
  add_foreign_key "members", "users"
  add_foreign_key "team_members", "members"
  add_foreign_key "team_members", "teams"
  add_foreign_key "teams", "year_groups"
  add_foreign_key "year_groups", "seasons"
end
