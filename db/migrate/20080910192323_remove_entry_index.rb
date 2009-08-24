class RemoveEntryIndex < ActiveRecord::Migration
  def self.up
    remove_index :entries, :slug
  end

  def self.down
    add_index :entries, :slug
  end
end
