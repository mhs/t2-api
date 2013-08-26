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

ActiveRecord::Schema.define(:version => 20130823182509) do

  create_table "allocations", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "project_id"
    t.integer  "person_id"
    t.boolean  "billable"
    t.boolean  "binding"
    t.text     "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "slot_id"
  end

  add_index "allocations", ["billable"], :name => "index_allocations_on_billable"
  add_index "allocations", ["binding"], :name => "index_allocations_on_binding"
  add_index "allocations", ["end_date"], :name => "index_allocations_on_end_date"
  add_index "allocations", ["person_id"], :name => "index_allocations_on_person_id"
  add_index "allocations", ["project_id"], :name => "index_allocations_on_project_id"
  add_index "allocations", ["slot_id"], :name => "index_allocations_on_slot_id"
  add_index "allocations", ["start_date"], :name => "index_allocations_on_start_date"

  create_table "api_consumers", :force => true do |t|
    t.string   "name"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "offices", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
    t.string   "slug"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.integer  "office_id"
    t.string   "email"
    t.text     "notes"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.time     "deleted_at"
    t.boolean  "unsellable", :default => false, :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "user_id"
  end

  add_index "people", ["end_date"], :name => "index_people_on_end_date"
  add_index "people", ["office_id"], :name => "index_people_on_office_id"
  add_index "people", ["start_date"], :name => "index_people_on_start_date"
  add_index "people", ["unsellable"], :name => "index_people_on_unsellable"

  create_table "project_offices", :force => true do |t|
    t.integer "project_id", :null => false
    t.integer "office_id",  :null => false
  end

  add_index "project_offices", ["project_id", "office_id"], :name => "index_project_offices_on_project_id_and_office_id", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.boolean  "billable",            :default => false, :null => false
    t.boolean  "binding",             :default => false, :null => false
    t.text     "notes"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "slug"
    t.time     "deleted_at"
    t.integer  "client_principal_id"
    t.boolean  "vacation",            :default => false
  end

  add_index "projects", ["billable"], :name => "index_projects_on_billable"
  add_index "projects", ["binding"], :name => "index_projects_on_binding"

  create_table "slots", :force => true do |t|
    t.integer  "project_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "t2_applications", :force => true do |t|
    t.string   "url"
    t.string   "icon"
    t.string   "title"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "admin"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "name"
    t.integer  "office_id"
    t.string   "date_format"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true

end
