# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090324175929) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.string   "timezone"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "api_key"
  end

  create_table "emails", :force => true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "from"
    t.string   "to"
    t.string   "subject"
    t.string   "body"
    t.boolean  "accepted",       :default => false
    t.text     "message_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_imports", :force => true do |t|
    t.integer  "account_id"
    t.integer  "rows_in_source"
    t.integer  "rows_imported"
    t.string   "source_file_name"
    t.string   "source_content_type"
    t.integer  "source_file_size"
    t.datetime "source_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "account_id",       :null => false
    t.integer  "subject_id"
    t.integer  "user_id"
    t.string   "state"
    t.string   "kind"
    t.text     "body"
    t.datetime "start"
    t.datetime "stop"
    t.date     "date"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name"
    t.datetime "state_changed_at"
    t.text     "tag"
    t.string   "import_token"
    t.datetime "imported_id"
    t.integer  "created_by_id"
  end

  add_index "events", ["import_token"], :name => "index_events_on_import_token"

  create_table "labels", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.integer  "taggings_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_duration"
  end

  create_table "punches", :force => true do |t|
    t.integer  "event_id"
    t.string   "from_state"
    t.string   "to_state"
    t.integer  "duration"
    t.datetime "start"
    t.datetime "stop"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "label_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
    t.date     "date"
  end

  create_table "trackables", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",      :default => "active"
  end

  add_index "trackables", ["state"], :name => "index_trackables_on_state"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.integer  "account_id"
    t.string   "api_key"
  end

  add_index "users", ["login", "account_id"], :name => "index_users_on_login_and_account_id", :unique => true

end
