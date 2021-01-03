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

ActiveRecord::Schema.define(version: 2021_01_03_161301) do

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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "discord_user_id"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
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

  create_table "challonge_tournaments", force: :cascade do |t|
    t.integer "challonge_id", null: false
    t.string "slug", null: false
    t.string "name"
    t.datetime "start_at"
    t.integer "participants_count"
    t.string "top1_participant_name"
    t.string "top2_participant_name"
    t.string "top3_participant_name"
    t.string "top4_participant_name"
    t.string "top5a_participant_name"
    t.string "top5b_participant_name"
    t.string "top7a_participant_name"
    t.string "top7b_participant_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["challonge_id"], name: "index_challonge_tournaments_on_challonge_id", unique: true
    t.index ["slug"], name: "index_challonge_tournaments_on_slug", unique: true
  end

  create_table "characters", force: :cascade do |t|
    t.string "icon"
    t.string "name"
    t.string "emoji"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "background_color"
    t.text "background_image"
    t.integer "background_size"
    t.string "ultimateframedata_url"
    t.string "smashprotips_url"
  end

  create_table "characters_players", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "player_id", null: false
    t.integer "position"
    t.index ["character_id", "player_id"], name: "index_characters_players_on_character_id_and_player_id", unique: true
    t.index ["character_id"], name: "index_characters_players_on_character_id"
    t.index ["player_id"], name: "index_characters_players_on_player_id"
  end

  create_table "discord_guild_admins", force: :cascade do |t|
    t.bigint "discord_guild_id", null: false
    t.bigint "discord_user_id", null: false
    t.string "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discord_guild_id", "discord_user_id"], name: "index_dga_on_both_ids", unique: true
    t.index ["discord_guild_id"], name: "index_discord_guild_admins_on_discord_guild_id"
    t.index ["discord_user_id"], name: "index_discord_guild_admins_on_discord_user_id"
  end

  create_table "discord_guild_relateds", force: :cascade do |t|
    t.bigint "discord_guild_id"
    t.string "related_type"
    t.bigint "related_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discord_guild_id", "related_type", "related_id"], name: "index_dgr_on_all", unique: true
    t.index ["discord_guild_id"], name: "index_discord_guild_relateds_on_discord_guild_id"
    t.index ["related_type", "related_id"], name: "index_discord_guild_relateds_on_related_type_and_related_id"
  end

  create_table "discord_guilds", force: :cascade do |t|
    t.string "discord_id"
    t.string "name"
    t.string "icon"
    t.string "splash"
    t.string "old_related_type"
    t.bigint "old_related_id"
    t.string "invitation_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "twitter_username"
    t.index ["old_related_type", "old_related_id"], name: "index_discord_guilds_on_old_related_type_and_old_related_id"
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
    t.float "latitude"
    t.float "longitude"
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

  create_table "player_reward_conditions", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "reward_condition_id", null: false
    t.bigint "tournament_event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id", "reward_condition_id", "tournament_event_id"], name: "index_prc_on_all", unique: true
    t.index ["player_id"], name: "index_player_reward_conditions_on_player_id"
    t.index ["reward_condition_id"], name: "index_player_reward_conditions_on_reward_condition_id"
    t.index ["tournament_event_id"], name: "index_player_reward_conditions_on_tournament_event_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.boolean "is_accepted"
    t.bigint "discord_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "character_names", default: [], array: true
    t.bigint "creator_id"
    t.text "location_names", default: [], array: true
    t.text "team_names", default: [], array: true
    t.string "twitter_username"
    t.boolean "is_banned", default: false, null: false
    t.text "ban_details"
    t.integer "points", default: 0, null: false
    t.bigint "best_player_reward_condition_id"
    t.string "best_reward_level1"
    t.string "best_reward_level2"
    t.integer "rank"
    t.index ["best_player_reward_condition_id"], name: "index_players_on_best_player_reward_condition_id"
    t.index ["creator_id"], name: "index_players_on_creator_id"
    t.index ["discord_user_id"], name: "index_players_on_discord_user_id"
  end

  create_table "players_teams", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "team_id", null: false
    t.integer "position"
    t.index ["player_id", "team_id"], name: "index_players_teams_on_player_id_and_team_id", unique: true
    t.index ["player_id"], name: "index_players_teams_on_player_id"
    t.index ["team_id"], name: "index_players_teams_on_team_id"
  end

  create_table "recurring_tournament_contacts", force: :cascade do |t|
    t.bigint "recurring_tournament_id"
    t.bigint "discord_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discord_user_id"], name: "index_recurring_tournament_contacts_on_discord_user_id"
    t.index ["recurring_tournament_id", "discord_user_id"], name: "index_rtc_on_both_ids", unique: true
    t.index ["recurring_tournament_id"], name: "index_recurring_tournament_contacts_on_recurring_tournament_id"
  end

  create_table "recurring_tournaments", force: :cascade do |t|
    t.string "name", null: false
    t.string "recurring_type", null: false
    t.integer "wday"
    t.time "starts_at"
    t.bigint "discord_guild_id"
    t.boolean "is_online", default: false, null: false
    t.string "level"
    t.integer "size"
    t.text "registration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "date_description"
    t.boolean "is_archived", default: false, null: false
    t.index ["discord_guild_id"], name: "index_recurring_tournaments_on_discord_guild_id"
  end

  create_table "reward_conditions", force: :cascade do |t|
    t.bigint "reward_id"
    t.integer "size_min", null: false
    t.integer "size_max", null: false
    t.integer "rank", null: false
    t.integer "points", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reward_id"], name: "index_reward_conditions_on_reward_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "level1", null: false
    t.integer "level2", null: false
    t.string "emoji", null: false
    t.index ["level1", "level2"], name: "index_rewards_on_level1_and_level2", unique: true
  end

  create_table "smashgg_events", force: :cascade do |t|
    t.integer "smashgg_id", null: false
    t.string "slug", null: false
    t.string "name"
    t.datetime "start_at"
    t.boolean "is_online"
    t.integer "num_entrants"
    t.integer "tournament_id"
    t.string "tournament_slug"
    t.string "tournament_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "top1_smashgg_user_id"
    t.bigint "top2_smashgg_user_id"
    t.bigint "top3_smashgg_user_id"
    t.bigint "top4_smashgg_user_id"
    t.bigint "top5a_smashgg_user_id"
    t.bigint "top5b_smashgg_user_id"
    t.bigint "top7a_smashgg_user_id"
    t.bigint "top7b_smashgg_user_id"
    t.index ["slug"], name: "index_smashgg_events_on_slug", unique: true
    t.index ["smashgg_id"], name: "index_smashgg_events_on_smashgg_id", unique: true
    t.index ["top1_smashgg_user_id"], name: "index_smashgg_events_on_top1_smashgg_user_id"
    t.index ["top2_smashgg_user_id"], name: "index_smashgg_events_on_top2_smashgg_user_id"
    t.index ["top3_smashgg_user_id"], name: "index_smashgg_events_on_top3_smashgg_user_id"
    t.index ["top4_smashgg_user_id"], name: "index_smashgg_events_on_top4_smashgg_user_id"
    t.index ["top5a_smashgg_user_id"], name: "index_smashgg_events_on_top5a_smashgg_user_id"
    t.index ["top5b_smashgg_user_id"], name: "index_smashgg_events_on_top5b_smashgg_user_id"
    t.index ["top7a_smashgg_user_id"], name: "index_smashgg_events_on_top7a_smashgg_user_id"
    t.index ["top7b_smashgg_user_id"], name: "index_smashgg_events_on_top7b_smashgg_user_id"
  end

  create_table "smashgg_users", force: :cascade do |t|
    t.integer "smashgg_id", null: false
    t.string "slug", null: false
    t.bigint "player_id"
    t.text "bio"
    t.string "birthday"
    t.string "gender_pronoun"
    t.string "name"
    t.string "city"
    t.string "country"
    t.string "country_id"
    t.string "state"
    t.string "state_id"
    t.string "smashgg_player_id"
    t.string "gamer_tag"
    t.string "prefix"
    t.string "banner_url"
    t.string "avatar_url"
    t.string "discord_discriminated_username"
    t.string "twitch_username"
    t.string "twitter_username"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_smashgg_users_on_player_id"
    t.index ["slug"], name: "index_smashgg_users_on_slug", unique: true
    t.index ["smashgg_id"], name: "index_smashgg_users_on_smashgg_id", unique: true
  end

  create_table "team_admins", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "discord_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discord_user_id"], name: "index_team_admins_on_discord_user_id"
    t.index ["team_id", "discord_user_id"], name: "index_team_admins_on_team_id_and_discord_user_id", unique: true
    t.index ["team_id"], name: "index_team_admins_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_offline"
    t.boolean "is_online"
    t.boolean "is_sponsor"
    t.string "twitter_username"
  end

  create_table "tournament_events", force: :cascade do |t|
    t.bigint "recurring_tournament_id"
    t.string "name", null: false
    t.date "date", null: false
    t.bigint "top1_player_id"
    t.bigint "top2_player_id"
    t.bigint "top3_player_id"
    t.bigint "top4_player_id"
    t.bigint "top5a_player_id"
    t.bigint "top5b_player_id"
    t.bigint "top7a_player_id"
    t.bigint "top7b_player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "participants_count"
    t.string "bracket_url"
    t.boolean "is_complete", default: false, null: false
    t.string "bracket_type"
    t.bigint "bracket_id"
    t.index ["bracket_type", "bracket_id"], name: "index_tournament_events_on_bracket_type_and_bracket_id"
    t.index ["recurring_tournament_id"], name: "index_tournament_events_on_recurring_tournament_id"
    t.index ["top1_player_id"], name: "index_tournament_events_on_top1_player_id"
    t.index ["top2_player_id"], name: "index_tournament_events_on_top2_player_id"
    t.index ["top3_player_id"], name: "index_tournament_events_on_top3_player_id"
    t.index ["top4_player_id"], name: "index_tournament_events_on_top4_player_id"
    t.index ["top5a_player_id"], name: "index_tournament_events_on_top5a_player_id"
    t.index ["top5b_player_id"], name: "index_tournament_events_on_top5b_player_id"
    t.index ["top7a_player_id"], name: "index_tournament_events_on_top7a_player_id"
    t.index ["top7b_player_id"], name: "index_tournament_events_on_top7b_player_id"
  end

  create_table "twitch_channels", force: :cascade do |t|
    t.string "username", null: false
    t.boolean "is_french", default: false, null: false
    t.string "related_type"
    t.bigint "related_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.index ["related_type", "related_id"], name: "index_twitch_channels_on_related_type_and_related_id"
    t.index ["username"], name: "index_twitch_channels_on_username", unique: true
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

  create_table "you_tube_channels", force: :cascade do |t|
    t.string "username", null: false
    t.boolean "is_french", default: false, null: false
    t.string "related_type"
    t.bigint "related_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.index ["related_type", "related_id"], name: "index_you_tube_channels_on_related_type_and_related_id"
    t.index ["username"], name: "index_you_tube_channels_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "player_reward_conditions", "players"
  add_foreign_key "player_reward_conditions", "reward_conditions"
  add_foreign_key "player_reward_conditions", "tournament_events"
  add_foreign_key "players", "player_reward_conditions", column: "best_player_reward_condition_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top1_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top2_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top3_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top4_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top5a_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top5b_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top7a_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top7b_smashgg_user_id"
  add_foreign_key "smashgg_users", "players"
  add_foreign_key "tournament_events", "players", column: "top1_player_id"
  add_foreign_key "tournament_events", "players", column: "top2_player_id"
  add_foreign_key "tournament_events", "players", column: "top3_player_id"
  add_foreign_key "tournament_events", "players", column: "top4_player_id"
  add_foreign_key "tournament_events", "players", column: "top5a_player_id"
  add_foreign_key "tournament_events", "players", column: "top5b_player_id"
  add_foreign_key "tournament_events", "players", column: "top7a_player_id"
  add_foreign_key "tournament_events", "players", column: "top7b_player_id"
  add_foreign_key "tournament_events", "recurring_tournaments"
end
