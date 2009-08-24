class RemoveEntryPolymorphism < ActiveRecord::Migration
  def self.up
		remove_column :entries, :content_id
		remove_column :entries, :content_type

		drop_table :posts
		drop_table :links
		drop_table :quotes
  end

  def self.down
		add_column :entries, :content_id
		add_column :entries, :content_type

		# This is pretty much a non-reversable migration if 
		# you want to bring those tables back you're probably 
		# better off migrating to an earlier version, sorry.
  end
end
