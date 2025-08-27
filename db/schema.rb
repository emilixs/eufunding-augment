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

ActiveRecord::Schema[8.0].define(version: 2025_08_27_122423) do
  create_table "api_logs", force: :cascade do |t|
    t.string "cui", null: false
    t.text "request_url", null: false
    t.string "http_method", null: false
    t.text "request_headers"
    t.text "request_body"
    t.integer "response_status"
    t.text "response_headers"
    t.text "response_body"
    t.decimal "request_duration", precision: 8, scale: 4
    t.text "error_message"
    t.string "user_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_api_logs_on_created_at"
    t.index ["cui"], name: "index_api_logs_on_cui"
    t.index ["response_status"], name: "index_api_logs_on_response_status"
  end

  create_table "chats", force: :cascade do |t|
    t.string "model_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.string "role"
    t.text "content"
    t.string "model_id"
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.integer "tool_call_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["tool_call_id"], name: "index_messages_on_tool_call_id"
  end

  create_table "tool_calls", force: :cascade do |t|
    t.integer "message_id", null: false
    t.string "tool_call_id", null: false
    t.string "name", null: false
    t.json "arguments", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_tool_calls_on_message_id"
    t.index ["tool_call_id"], name: "index_tool_calls_on_tool_call_id"
  end

  add_foreign_key "messages", "chats"
  add_foreign_key "tool_calls", "messages"
end
