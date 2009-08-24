class BasicTables < ActiveRecord::Migration
  def self.up
    # Entries are the core type
    create_table :entries do |t|
      t.column :content_id,     :integer, :null=>false
      t.column :content_type,   :string
      t.column :comments_count, :integer, :default=>0
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
    end
    
    # Entries can be posts, links or quotes
    create_table :posts do |t|
      t.column :title,        :string
      t.column :content,      :text
    end
    create_table :links do |t|
      t.column :href,         :string
      t.column :text,         :string
      t.column :description,  :string
      t.column :checksum,     :string
    end
    create_table :quotes do |t|
      t.column :quote,        :text
      t.column :attribution,  :string
      t.column :source,       :string
    end
    add_index :links, :href
    
    # Entries can be tagged
    create_table :tags do |t|
      t.column :name, :string
    end
    create_table :entries_tags, :id => false do |t|
      t.column :entry_id,   :integer, :null=>false
      t.column :tag_id,     :integer, :null=>false
    end
    add_index :entries_tags, [:entry_id, :tag_id]
    add_index :entries_tags, :tag_id
    
    # Entries can be commented upon
    create_table :comments do |t|
      t.column :entry_id,   :integer, :null=>false
      t.column :parent_id,  :integer
      t.column :content,    :text
      t.column :name,       :string
      t.column :href,       :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :entries

    drop_table :posts
    drop_table :links
    drop_table :quotes

    drop_table :tags
    drop_table :entries_tags

    drop_table :comments
  end
end
