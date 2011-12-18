class CreateImageTable < ActiveRecord::Migration
  def self.up

    create_table :book_images do |t|
      t.column :book_id,    :integer, :null=>false
      t.column :url,        :string
      t.column :height,     :integer, :null=>false
      t.column :width,      :integer, :null=>false
      t.column :image_type, :string
    end

    add_index :book_images, :book_id

  end

  def self.down
    drop_table :book_images
  end
end
