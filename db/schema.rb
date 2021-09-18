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

ActiveRecord::Schema.define(version: 2021_09_02_150201) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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

  create_table "braacket_tournaments", force: :cascade do |t|
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
    t.boolean "is_ignored", default: false, null: false
    t.index ["slug"], name: "index_braacket_tournaments_on_slug", unique: true
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
    t.boolean "is_ignored", default: false, null: false
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

  create_table "communities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.string "address", null: false
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
    t.integer "discord_guild_id", null: false
    t.string "related_type", null: false
    t.integer "related_id", null: false
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
    t.string "invitation_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "twitter_username"
  end

  create_table "discord_users", force: :cascade do |t|
    t.string "discord_id"
    t.string "username"
    t.string "discriminator"
    t.string "avatar"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["discord_id"], name: "index_discord_users_on_discord_id", unique: true
    t.index ["user_id"], name: "index_discord_users_on_user_id"
  end

  create_table "duo_tournament_events", force: :cascade do |t|
    t.integer "recurring_tournament_id"
    t.string "name", null: false
    t.date "date", null: false
    t.integer "participants_count"
    t.string "bracket_url"
    t.string "bracket_type"
    t.bigint "bracket_id"
    t.bigint "top1_duo_id"
    t.bigint "top2_duo_id"
    t.bigint "top3_duo_id"
    t.bigint "top4_duo_id"
    t.bigint "top5a_duo_id"
    t.bigint "top5b_duo_id"
    t.bigint "top7a_duo_id"
    t.bigint "top7b_duo_id"
    t.boolean "is_complete", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_out_of_ranking", default: false, null: false
    t.boolean "is_online", default: false, null: false
    t.text "not_duplicates", default: [], array: true
    t.index ["bracket_type", "bracket_id"], name: "index_duo_tournament_events_on_bracket_type_and_bracket_id"
    t.index ["recurring_tournament_id"], name: "index_duo_tournament_events_on_recurring_tournament_id"
    t.index ["top1_duo_id"], name: "index_duo_tournament_events_on_top1_duo_id"
    t.index ["top2_duo_id"], name: "index_duo_tournament_events_on_top2_duo_id"
    t.index ["top3_duo_id"], name: "index_duo_tournament_events_on_top3_duo_id"
    t.index ["top4_duo_id"], name: "index_duo_tournament_events_on_top4_duo_id"
    t.index ["top5a_duo_id"], name: "index_duo_tournament_events_on_top5a_duo_id"
    t.index ["top5b_duo_id"], name: "index_duo_tournament_events_on_top5b_duo_id"
    t.index ["top7a_duo_id"], name: "index_duo_tournament_events_on_top7a_duo_id"
    t.index ["top7b_duo_id"], name: "index_duo_tournament_events_on_top7b_duo_id"
  end

  create_table "duos", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "player1_id", null: false
    t.bigint "player2_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_duos_on_name"
    t.index ["player1_id"], name: "index_duos_on_player1_id"
    t.index ["player2_id"], name: "index_duos_on_player2_id"
  end

  create_table "met_reward_conditions", force: :cascade do |t|
    t.string "awarded_type", null: false
    t.bigint "awarded_id", null: false
    t.bigint "reward_condition_id", null: false
    t.string "event_type", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["awarded_type", "awarded_id", "reward_condition_id", "event_type", "event_id"], name: "index_mrc_on_all", unique: true
    t.index ["awarded_type", "awarded_id"], name: "index_met_reward_conditions_on_awarded_type_and_awarded_id"
    t.index ["event_type", "event_id"], name: "index_met_reward_conditions_on_event_type_and_event_id"
    t.index ["reward_condition_id"], name: "index_met_reward_conditions_on_reward_condition_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "parent_id"
    t.boolean "is_draft", default: false, null: false
    t.boolean "in_header", default: false, null: false
    t.boolean "in_footer", default: false, null: false
    t.index ["parent_id"], name: "index_pages_on_parent_id"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
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
    t.string "name"
    t.boolean "is_accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "character_names", default: [], array: true
    t.text "team_names", default: [], array: true
    t.boolean "is_banned", default: false, null: false
    t.text "ban_details"
    t.integer "creator_user_id", null: false
    t.integer "user_id"
    t.string "old_names", default: [], array: true
    t.index ["creator_user_id"], name: "index_players_on_creator_user_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "players_recurring_tournaments", force: :cascade do |t|
    t.bigint "player_id"
    t.bigint "recurring_tournament_id"
    t.boolean "has_good_network", default: false, null: false
    t.bigint "certifier_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["certifier_user_id"], name: "index_players_recurring_tournaments_on_certifier_user_id"
    t.index ["player_id", "recurring_tournament_id"], name: "index_prt_on_both_ids", unique: true
    t.index ["player_id"], name: "index_players_recurring_tournaments_on_player_id"
    t.index ["recurring_tournament_id"], name: "index_players_recurring_tournaments_on_recurring_tournament_id"
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
    t.integer "recurring_tournament_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id", null: false
    t.index ["recurring_tournament_id", "user_id"], name: "index_rtc_on_both_ids", unique: true
    t.index ["recurring_tournament_id"], name: "index_recurring_tournament_contacts_on_recurring_tournament_id"
    t.index ["user_id"], name: "index_recurring_tournament_contacts_on_user_id"
  end

  create_table "recurring_tournaments", force: :cascade do |t|
    t.string "name", null: false
    t.string "recurring_type", null: false
    t.integer "wday"
    t.bigint "discord_guild_id"
    t.boolean "is_online", default: false, null: false
    t.string "level"
    t.integer "size"
    t.text "registration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "date_description"
    t.boolean "is_archived", default: false, null: false
    t.integer "starts_at_hour", null: false
    t.integer "starts_at_min", null: false
    t.string "address_name"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.string "twitter_username"
    t.text "misc"
    t.boolean "is_hidden", default: false, null: false
    t.string "locality"
    t.string "countrycode"
    t.index ["discord_guild_id"], name: "index_recurring_tournaments_on_discord_guild_id"
  end

  create_table "reward_conditions", force: :cascade do |t|
    t.integer "reward_id", null: false
    t.integer "size_min", null: false
    t.integer "size_max", null: false
    t.integer "rank", null: false
    t.integer "points", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_online", default: false, null: false
    t.boolean "is_duo", default: false, null: false
    t.index ["reward_id"], name: "index_reward_conditions_on_reward_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "level1", null: false
    t.integer "level2", null: false
    t.string "category", null: false
    t.index ["category", "level1", "level2"], name: "index_rewards_on_category_and_level1_and_level2", unique: true
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
    t.boolean "is_ignored", default: false, null: false
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id", null: false
    t.index ["team_id", "user_id"], name: "index_team_admins_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_admins_on_team_id"
    t.index ["user_id"], name: "index_team_admins_on_user_id"
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
    t.integer "recurring_tournament_id"
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
    t.boolean "is_out_of_ranking", default: false, null: false
    t.boolean "is_online", default: false, null: false
    t.text "not_duplicates", default: [], array: true
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

  create_table "track_records", force: :cascade do |t|
    t.string "tracked_type", null: false
    t.bigint "tracked_id", null: false
    t.integer "year"
    t.boolean "is_online", default: false, null: false
    t.integer "points", null: false
    t.integer "rank"
    t.integer "best_met_reward_condition_id"
    t.string "best_reward_level1"
    t.string "best_reward_level2"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tracked_type", "tracked_id", "year", "is_online"], name: "index_track_records_on_all", unique: true
    t.index ["tracked_type", "tracked_id"], name: "index_track_records_on_tracked_type_and_tracked_id"
  end

  create_table "twitch_channels", force: :cascade do |t|
    t.string "slug", null: false
    t.boolean "is_french", default: false, null: false
    t.string "related_type"
    t.bigint "related_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "twitch_id"
    t.string "name"
    t.string "twitch_description"
    t.string "profile_image_url"
    t.datetime "twitch_created_at"
    t.index ["related_type", "related_id"], name: "index_twitch_channels_on_related_type_and_related_id"
    t.index ["slug"], name: "index_twitch_channels_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "is_root", default: false, null: false
    t.string "admin_level"
    t.string "name", null: false
    t.boolean "is_caster", default: false, null: false
    t.boolean "is_coach", default: false, null: false
    t.string "coaching_url"
    t.string "coaching_details"
    t.boolean "is_graphic_designer", default: false, null: false
    t.string "graphic_designer_details"
    t.boolean "is_available_graphic_designer", default: false, null: false
    t.string "twitter_username"
    t.datetime "remember_created_at"
    t.string "main_address"
    t.float "main_latitude"
    t.float "main_longitude"
    t.string "secondary_address"
    t.float "secondary_latitude"
    t.float "secondary_longitude"
    t.string "main_locality"
    t.string "secondary_locality"
    t.string "main_countrycode", default: "", null: false
    t.string "secondary_countrycode", default: "", null: false
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
    t.boolean "is_french", default: false, null: false
    t.string "related_type"
    t.bigint "related_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.string "url", null: false
    t.index ["related_type", "related_id"], name: "index_you_tube_channels_on_related_type_and_related_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "characters_players", "characters"
  add_foreign_key "characters_players", "players"
  add_foreign_key "discord_guild_admins", "discord_guilds"
  add_foreign_key "discord_guild_admins", "discord_users"
  add_foreign_key "discord_guild_relateds", "discord_guilds"
  add_foreign_key "discord_users", "users"
  add_foreign_key "duo_tournament_events", "duos", column: "top1_duo_id"
  add_foreign_key "duo_tournament_events", "duos", column: "top2_duo_id"
  add_foreign_key "duo_tournament_events", "duos", column: "top3_duo_id"
  add_foreign_key "duo_tournament_events", "duos", column: "top4_duo_id"
  add_foreign_key "duo_tournament_events", "duos", column: "top5a_duo_id"
  add_foreign_key "duo_tournament_events", "duos", column: "top5b_duo_id"
  add_foreign_key "duo_tournament_events", "duos", column: "top7a_duo_id"
  add_foreign_key "duo_tournament_events", "duos", column: "top7b_duo_id"
  add_foreign_key "duo_tournament_events", "recurring_tournaments"
  add_foreign_key "duos", "players", column: "player1_id"
  add_foreign_key "duos", "players", column: "player2_id"
  add_foreign_key "met_reward_conditions", "reward_conditions"
  add_foreign_key "pages", "pages", column: "parent_id"
  add_foreign_key "players", "users"
  add_foreign_key "players", "users", column: "creator_user_id"
  add_foreign_key "players_recurring_tournaments", "players"
  add_foreign_key "players_recurring_tournaments", "recurring_tournaments"
  add_foreign_key "players_recurring_tournaments", "users", column: "certifier_user_id"
  add_foreign_key "players_teams", "players"
  add_foreign_key "players_teams", "teams"
  add_foreign_key "recurring_tournament_contacts", "recurring_tournaments"
  add_foreign_key "recurring_tournament_contacts", "users"
  add_foreign_key "recurring_tournaments", "discord_guilds"
  add_foreign_key "reward_conditions", "rewards"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top1_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top2_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top3_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top4_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top5a_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top5b_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top7a_smashgg_user_id"
  add_foreign_key "smashgg_events", "smashgg_users", column: "top7b_smashgg_user_id"
  add_foreign_key "smashgg_users", "players"
  add_foreign_key "team_admins", "teams"
  add_foreign_key "team_admins", "users"
  add_foreign_key "tournament_events", "players", column: "top1_player_id"
  add_foreign_key "tournament_events", "players", column: "top2_player_id"
  add_foreign_key "tournament_events", "players", column: "top3_player_id"
  add_foreign_key "tournament_events", "players", column: "top4_player_id"
  add_foreign_key "tournament_events", "players", column: "top5a_player_id"
  add_foreign_key "tournament_events", "players", column: "top5b_player_id"
  add_foreign_key "tournament_events", "players", column: "top7a_player_id"
  add_foreign_key "tournament_events", "players", column: "top7b_player_id"
  add_foreign_key "tournament_events", "recurring_tournaments"
  add_foreign_key "track_records", "met_reward_conditions", column: "best_met_reward_condition_id"
end
