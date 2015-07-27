# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150628043600) do

  create_table "email_profile_images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email",      limit: 255
    t.string   "url",        limit: 255
    t.string   "image",      limit: 255
    t.boolean  "active",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_threads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",       limit: 4
    t.string   "thread_id",     limit: 255
    t.datetime "last_email_at"
    t.integer  "emails_count",  limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_email_threads_on_deleted_at", using: :btree
  end

  create_table "emails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "email_thread_id", limit: 4
    t.string   "message_id",      limit: 255
    t.string   "from_email",      limit: 255
    t.string   "from_name",       limit: 255
    t.string   "to_email",        limit: 255
    t.string   "to_name",         limit: 255
    t.string   "subject",         limit: 255
    t.text     "body",            limit: 65535
    t.string   "content_type",    limit: 255
    t.datetime "received_on"
    t.integer  "questions_count", limit: 4,     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_emails_on_deleted_at", using: :btree
  end

  create_table "questions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "email_id",   limit: 4
    t.text     "question",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_questions_on_deleted_at", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email",                  limit: 255, default: "",                           null: false
    t.string   "encrypted_password",     limit: 255, default: "",                           null: false
    t.string   "image_url",              limit: 255
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,                            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "name",                   limit: 255
    t.string   "omniauth_token",         limit: 255
    t.string   "omniauth_refresh_token", limit: 255
    t.datetime "omniauth_expires_at"
    t.boolean  "omniauth_expires"
    t.string   "time_zone",              limit: 255, default: "Pacific Time (US & Canada)"
    t.datetime "email_send",                         default: '2014-01-01 17:00:00'
    t.boolean  "admin",                              default: false
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
