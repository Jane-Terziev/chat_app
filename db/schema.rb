# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_01_31_155021) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "user_id"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chat_message_links", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "message_id"
    t.string "link", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_chat_message_links_on_message_id"
  end

  create_table "chat_participants", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "user_id"
    t.string "chat_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_chat_participants_on_chat_id"
    t.index ["user_id"], name: "index_chat_participants_on_user_id"
  end

  create_table "chats", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "name"
    t.string "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "messages", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "message"
    t.string "chat_participant_id"
    t.string "chat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_type"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["chat_participant_id"], name: "index_messages_on_chat_participant_id"
  end

  create_table "unacknowledged_messages", force: :cascade do |t|
    t.string "message_id"
    t.string "user_id"
    t.string "chat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_unacknowledged_messages_on_chat_id"
    t.index ["message_id"], name: "index_unacknowledged_messages_on_message_id"
    t.index ["user_id"], name: "index_unacknowledged_messages_on_user_id"
  end

  create_table "users", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "time_zone"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_message_links", "messages"
  add_foreign_key "chat_participants", "chats"
  add_foreign_key "chat_participants", "users"
  add_foreign_key "chats", "users"
  add_foreign_key "messages", "chat_participants"
  add_foreign_key "messages", "chats"
  add_foreign_key "unacknowledged_messages", "chats"
  add_foreign_key "unacknowledged_messages", "messages"
  add_foreign_key "unacknowledged_messages", "users"

  create_view "chat_participant_views", sql_definition: <<-SQL
      SELECT cp.id,
      cp.user_id,
      cp.chat_id,
      cp.status,
      u.first_name,
      u.last_name
     FROM (users u
       LEFT JOIN chat_participants cp ON (((cp.user_id)::text = (u.id)::text)));
  SQL
  create_view "message_list_views", sql_definition: <<-SQL
      SELECT m.id,
      m.chat_id,
      m.message,
      cp.user_id,
      m.message_type,
      m.created_at
     FROM (messages m
       JOIN chat_participants cp ON (((m.chat_participant_id)::text = (cp.id)::text)));
  SQL
  create_view "chat_list_views", sql_definition: <<-SQL
      SELECT c.id,
      c.name,
      cp.user_id,
      last_message.message AS last_message,
      last_message.created_at AS last_message_timestamp,
      COALESCE(um.unread_messages_count, (0)::bigint) AS unread_messages_count,
      COALESCE(total_messages.total_messages_count, (0)::bigint) AS total_messages_count,
      c.created_at,
      c.updated_at
     FROM ((((chats c
       JOIN chat_participants cp ON (((c.id)::text = (cp.chat_id)::text)))
       LEFT JOIN ( SELECT messages.chat_id,
              count(*) AS total_messages_count
             FROM messages
            GROUP BY messages.chat_id) total_messages ON (((total_messages.chat_id)::text = (c.id)::text)))
       LEFT JOIN ( SELECT messages.chat_id,
              messages.message,
              messages.created_at
             FROM (messages
               JOIN ( SELECT messages_1.chat_id,
                      max(messages_1.created_at) AS max_created_at
                     FROM messages messages_1
                    GROUP BY messages_1.chat_id) m ON ((((m.chat_id)::text = (messages.chat_id)::text) AND (m.max_created_at = messages.created_at))))) last_message ON (((last_message.chat_id)::text = (c.id)::text)))
       LEFT JOIN ( SELECT unacknowledged_messages.chat_id,
              unacknowledged_messages.user_id,
              count(*) AS unread_messages_count
             FROM unacknowledged_messages
            GROUP BY unacknowledged_messages.chat_id, unacknowledged_messages.user_id) um ON ((((c.id)::text = (um.chat_id)::text) AND ((cp.user_id)::text = (um.user_id)::text))))
    WHERE ((cp.status)::text = 'active'::text);
  SQL
end
