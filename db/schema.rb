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

ActiveRecord::Schema[7.1].define(version: 2025_08_17_011046) do
  create_table "books", force: :cascade do |t|
    t.string "title", limit: 200, null: false
    t.string "author", limit: 100, null: false
    t.string "isbn", limit: 13
    t.text "description", limit: 1000
    t.integer "genre", default: 0, null: false
    t.date "published_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author"], name: "index_books_on_author"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
    t.index ["published_date"], name: "index_books_on_published_date"
  end

end
