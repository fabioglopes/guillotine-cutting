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

ActiveRecord::Schema[8.1].define(version: 2025_10_26_120630) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "pieces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "height"
    t.string "label"
    t.integer "project_id", null: false
    t.integer "quantity"
    t.decimal "thickness"
    t.datetime "updated_at", null: false
    t.integer "width"
    t.index ["project_id"], name: "index_pieces_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.boolean "allow_rotation"
    t.datetime "created_at", null: false
    t.integer "cutting_width"
    t.text "description"
    t.decimal "efficiency"
    t.string "name"
    t.integer "pieces_placed"
    t.integer "pieces_total"
    t.integer "sheets_used"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "sheets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "height"
    t.string "label"
    t.integer "project_id", null: false
    t.integer "quantity"
    t.decimal "thickness"
    t.datetime "updated_at", null: false
    t.integer "width"
    t.index ["project_id"], name: "index_sheets_on_project_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "pieces", "projects"
  add_foreign_key "sheets", "projects"
end
