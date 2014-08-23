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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111114013634) do

  create_table "daily_quotations", :force => true do |t|
    t.string   "paper",          :limit => 10
    t.date     "date_quotation"
    t.decimal  "open",                         :precision => 13, :scale => 2
    t.decimal  "close",                        :precision => 13, :scale => 2
    t.decimal  "high",                         :precision => 13, :scale => 2
    t.decimal  "low",                          :precision => 13, :scale => 2
    t.decimal  "volume",                       :precision => 13, :scale => 2
    t.string   "type_candle",    :limit => 1
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  create_table "papers", :force => true do |t|
    t.string   "symbol"
    t.string   "description"
    t.integer  "nr_lote"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "setup_candles", :force => true do |t|
    t.integer  "setup_id"
    t.string   "type_candle"
    t.string   "candle_position"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "setup_rels", :force => true do |t|
    t.integer  "setup_id"
    t.string   "candle_x_value"
    t.string   "candle_x_position"
    t.string   "value"
    t.string   "candle_y_value"
    t.string   "candle_y_position"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "setups", :force => true do |t|
    t.string   "setup"
    t.string   "description"
    t.integer  "quantity_candle"
    t.string   "fl_rel_candle"
    t.string   "first_candle",                     :default => "N"
    t.string   "second_candle",                    :default => "N"
    t.string   "third_candle",                     :default => "N"
    t.integer  "user_id"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "first_candle_type",  :limit => 20
    t.string   "second_candle_type", :limit => 20
    t.string   "third_candle_type",  :limit => 20
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                      :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "full_name",              :limit => 40
    t.boolean  "fl_admin"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "weekly_quotations", :force => true do |t|
    t.string   "paper",          :limit => 10
    t.date     "date_quotation"
    t.decimal  "open",                         :precision => 13, :scale => 2
    t.decimal  "close",                        :precision => 13, :scale => 2
    t.decimal  "high",                         :precision => 13, :scale => 2
    t.decimal  "low",                          :precision => 13, :scale => 2
    t.decimal  "volume",                       :precision => 13, :scale => 2
    t.string   "type_candle",    :limit => 1
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

end
