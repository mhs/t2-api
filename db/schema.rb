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

ActiveRecord::Schema.define(version: 20140429143404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "allocations", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "project_id"
    t.integer  "person_id"
    t.boolean  "billable"
    t.boolean  "binding"
    t.text     "notes"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "slot_id"
    t.integer  "percent_allocated", default: 100,   null: false
    t.boolean  "provisional",       default: false
  end

  add_index "allocations", ["billable"], name: "index_allocations_on_billable", using: :btree
  add_index "allocations", ["binding"], name: "index_allocations_on_binding", using: :btree
  add_index "allocations", ["end_date"], name: "index_allocations_on_end_date", using: :btree
  add_index "allocations", ["person_id"], name: "index_allocations_on_person_id", using: :btree
  add_index "allocations", ["project_id"], name: "index_allocations_on_project_id", using: :btree
  add_index "allocations", ["slot_id"], name: "index_allocations_on_slot_id", using: :btree
  add_index "allocations", ["start_date"], name: "index_allocations_on_start_date", using: :btree

  create_table "api_consumers", force: true do |t|
    t.string   "name"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "holidays", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "monthly_snapshots", force: true do |t|
    t.integer  "office_id"
    t.date     "snap_date"
    t.decimal  "assignable_days",      precision: 6, scale: 2, default: 0.0
    t.decimal  "billing_days",         precision: 6, scale: 2, default: 0.0
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.decimal  "utilization",          precision: 6, scale: 2, default: 0.0
    t.boolean  "includes_provisional",                         default: false
  end

  add_index "monthly_snapshots", ["office_id"], name: "index_monthly_snapshots_on_office_id", using: :btree
  add_index "monthly_snapshots", ["snap_date", "office_id", "includes_provisional"], name: "unique_monthly_snapshots_index", unique: true, using: :btree
  add_index "monthly_snapshots", ["snap_date"], name: "index_monthly_snapshots_on_snap_date", using: :btree

  create_table "office_holidays", force: true do |t|
    t.integer "office_id"
    t.integer "holiday_id"
  end

  create_table "offices", force: true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "slug"
    t.datetime "deleted_at"
    t.integer  "position"
  end

  create_table "people", force: true do |t|
    t.string   "name"
    t.integer  "office_id"
    t.string   "email"
    t.text     "notes"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "user_id"
    t.string   "github"
    t.string   "twitter"
    t.string   "website"
    t.string   "title"
    t.text     "bio"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "deleted_at"
    t.string   "role"
    t.integer  "percent_billable",      default: 100,  null: false
    t.boolean  "voluntary_termination", default: true
  end

  add_index "people", ["end_date"], name: "index_people_on_end_date", using: :btree
  add_index "people", ["office_id"], name: "index_people_on_office_id", using: :btree
  add_index "people", ["start_date"], name: "index_people_on_start_date", using: :btree

  create_table "project_offices", force: true do |t|
    t.integer "project_id", null: false
    t.integer "office_id",  null: false
  end

  add_index "project_offices", ["project_id", "office_id"], name: "index_project_offices_on_project_id_and_office_id", unique: true, using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.boolean  "billable",            default: true,  null: false
    t.boolean  "binding",             default: false, null: false
    t.text     "notes"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "slug"
    t.integer  "client_principal_id"
    t.boolean  "vacation",            default: false
    t.datetime "deleted_at"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "holiday",             default: false, null: false
    t.boolean  "provisional",         default: false
    t.boolean  "investment_fridays",  default: false
  end

  add_index "projects", ["billable"], name: "index_projects_on_billable", using: :btree
  add_index "projects", ["binding"], name: "index_projects_on_binding", using: :btree

  create_table "revenue_items", force: true do |t|
    t.integer  "project_id",                                             null: false
    t.integer  "allocation_id",                                          null: false
    t.integer  "office_id",                                              null: false
    t.integer  "person_id",                                              null: false
    t.string   "role",                                                   null: false
    t.date     "day",                                                    null: false
    t.boolean  "provisional",                            default: false
    t.decimal  "amount",        precision: 10, scale: 2, default: 0.0
    t.hstore   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revenue_items", ["day", "office_id", "project_id", "allocation_id", "person_id", "role", "provisional"], name: "index_all_the_things", unique: true, using: :btree

  create_table "snapshots", force: true do |t|
    t.text     "utilization"
    t.date     "snap_date"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "office_id"
    t.text     "staff"
    t.text     "unassignable"
    t.text     "billing"
    t.text     "assignable"
    t.text     "non_billing"
    t.text     "billable"
    t.text     "overallocated"
    t.text     "non_billable"
    t.boolean  "includes_provisional", default: false
  end

  add_index "snapshots", ["snap_date", "office_id", "includes_provisional"], name: "unique_snapshots_index", unique: true, using: :btree

  create_table "t2_applications", force: true do |t|
    t.string   "url"
    t.string   "icon"
    t.string   "title"
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "classes"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "admin"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "name"
    t.integer  "office_id"
    t.string   "date_format"
    t.string   "authentication_token"
    t.integer  "t2_application_id"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
