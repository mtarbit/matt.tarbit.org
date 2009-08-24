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

ActiveRecord::Schema.define(:version => 20090225185632) do

  create_table "authors", :force => true do |t|
    t.string "name"
  end

  create_table "authors_books", :id => false, :force => true do |t|
    t.integer "author_id", :limit => 11, :null => false
    t.integer "book_id",   :limit => 11, :null => false
  end

  add_index "authors_books", ["author_id"], :name => "index_authors_books_on_author_id"
  add_index "authors_books", ["book_id"], :name => "index_authors_books_on_book_id"

  create_table "book_images", :force => true do |t|
    t.integer "book_id",    :limit => 11, :null => false
    t.string  "url"
    t.integer "height",     :limit => 11, :null => false
    t.integer "width",      :limit => 11, :null => false
    t.string  "image_type"
  end

  add_index "book_images", ["book_id"], :name => "index_book_images_on_book_id"

  create_table "books", :force => true do |t|
    t.string   "title"
    t.string   "isbn"
    t.string   "asin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "entry_id",       :limit => 11,                :null => false
    t.integer  "parent_id",      :limit => 11
    t.text     "content"
    t.string   "name"
    t.string   "href"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "children_count", :limit => 11, :default => 0
    t.string   "website"
    t.string   "email"
    t.string   "ip"
  end

  create_table "entries", :force => true do |t|
    t.integer  "comments_count", :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "format"
    t.string   "slug"
    t.string   "title"
    t.text     "content"
    t.string   "url"
    t.string   "extra"
  end

  create_table "entries_tags", :id => false, :force => true do |t|
    t.integer "entry_id", :limit => 11, :null => false
    t.integer "tag_id",   :limit => 11, :null => false
  end

  add_index "entries_tags", ["entry_id", "tag_id"], :name => "index_entries_tags_on_entry_id_and_tag_id"
  add_index "entries_tags", ["tag_id"], :name => "index_entries_tags_on_tag_id"

  create_table "products", :force => true do |t|
    t.integer  "entry_id",   :limit => 11
    t.string   "asin",                     :null => false
    t.string   "url"
    t.string   "title"
    t.string   "image"
    t.string   "group"
    t.string   "creator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["entry_id"], :name => "index_products_on_entry_id"
  add_index "products", ["asin"], :name => "index_products_on_asin"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string "username"
    t.string "password_salt"
    t.string "password_hash"
  end

end
