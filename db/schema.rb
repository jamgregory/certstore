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

ActiveRecord::Schema.define(version: 20140501110830) do

  create_table "certificates", force: true do |t|
    t.text     "keytext",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "compromised",             default: false
  end

  add_index "certificates", ["keytext"], name: "index_certificates_on_keytext", unique: true

  create_table "scans", force: true do |t|
    t.integer  "service_id"
    t.integer  "certificate_id"
    t.string   "state"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scans", ["certificate_id"], name: "index_scans_on_certificate_id"
  add_index "scans", ["service_id"], name: "index_scans_on_service_id"

  create_table "services", force: true do |t|
    t.string   "address"
    t.string   "hostname"
    t.integer  "port"
    t.boolean  "current"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "retired",    default: false
  end

end
