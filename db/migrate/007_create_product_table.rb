class CreateProductTable < ActiveRecord::Migration
  def self.up

    create_table :products do |t|
      t.column :entry_id,   :integer
  	  t.column :asin,       :string, :null=>false
  	  t.column :url,        :string
  	  t.column :title,      :string
  	  t.column :image,      :string
  	  t.column :group,      :string
  	  t.column :creator,    :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :products, :entry_id
    add_index :products, :asin

  end

  def self.down
    drop_table :products
  end
end
