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

ActiveRecord::Schema.define(version: 2020_09_04_194529) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "discord_user_id"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "encrypted_password", default: "", null: false
    t.boolean "is_root", default: false, null: false
    t.string "level", null: false
    t.index ["discord_user_id"], name: "index_admin_users_on_discord_user_id", unique: true
  end

  create_table "api_requests", force: :cascade do |t|
    t.bigint "api_token_id"
    t.inet "remote_ip"
    t.string "controller"
    t.string "action"
    t.datetime "requested_at"
    t.index ["api_token_id"], name: "index_api_requests_on_api_token_id"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
  end

  create_table "characters", force: :cascade do |t|
    t.string "icon"
    t.string "name"
    t.string "emoji"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "characters_players", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "player_id", null: false
    t.integer "position"
    t.index ["character_id", "player_id"], name: "index_characters_players_on_character_id_and_player_id", unique: true
    t.index ["character_id"], name: "index_characters_players_on_character_id"
    t.index ["player_id"], name: "index_characters_players_on_player_id"
  end

  create_table "discord_users", force: :cascade do |t|
    t.string "discord_id"
    t.string "username"
    t.string "discriminator"
    t.string "avatar"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discord_id"], name: "index_discord_users_on_discord_id", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "icon"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.boolean "is_main"
    t.index ["type"], name: "index_locations_on_type"
  end

  create_table "locations_players", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "location_id", null: false
    t.integer "position"
    t.index ["location_id", "player_id"], name: "index_locations_players_on_location_id_and_player_id", unique: true
    t.index ["location_id"], name: "index_locations_players_on_location_id"
    t.index ["player_id"], name: "index_locations_players_on_player_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "location_id"
    t.bigint "team_id"
    t.string "name"
    t.boolean "is_accepted"
    t.bigint "discord_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "character_names", default: [], array: true
    t.bigint "creator_id"
    t.bigint "smash_gg_user_id"
    t.text "location_names", default: [], array: true
    t.text "team_names", default: [], array: true
    t.index ["creator_id"], name: "index_players_on_creator_id"
    t.index ["discord_user_id"], name: "index_players_on_discord_user_id"
    t.index ["location_id"], name: "index_players_on_location_id"
    t.index ["smash_gg_user_id"], name: "index_players_on_smash_gg_user_id"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "players_teams", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "team_id", null: false
    t.integer "position"
    t.index ["player_id", "team_id"], name: "index_players_teams_on_player_id_and_team_id", unique: true
    t.index ["player_id"], name: "index_players_teams_on_player_id"
    t.index ["team_id"], name: "index_players_teams_on_team_id"
  end

  create_table "smash_gg_users", force: :cascade do |t|
    t.integer "smashgg_id", null: false
    t.bigint "discord_user_id"
    t.text "bio"
    t.string "birthday"
    t.string "gender_pronoun"
    t.string "name"
    t.string "slug"
    t.string "city"
    t.string "country"
    t.string "country_id"
    t.string "state"
    t.string "state_id"
    t.string "player_id"
    t.string "gamer_tag"
    t.string "prefix"
    t.string "banner_url"
    t.string "avatar_url"
    t.string "discord_discriminated_username"
    t.string "twitch_username"
    t.string "twitter_username"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discord_user_id"], name: "index_smash_gg_users_on_discord_user_id"
    t.index ["smashgg_id"], name: "index_smash_gg_users_on_smashgg_id", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
