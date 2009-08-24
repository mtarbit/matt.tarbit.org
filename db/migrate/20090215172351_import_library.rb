class ImportLibrary < ActiveRecord::Migration

  def self.up

    create_table :books do |t|
  	  t.column :title,      :string
  	  t.column :isbn,       :string
  	  t.column :asin,       :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :authors do |t|
  	  t.column :name, :string
    end

    create_table :authors_books, :id => false do |t|
      t.column :author_id, :integer, :null=>false
      t.column :book_id,   :integer, :null=>false
    end
    add_index :authors_books, :author_id
    add_index :authors_books, :book_id

  end

  def self.down
    drop_table :books
    drop_table :authors
    drop_table :authors_books
  end
end

