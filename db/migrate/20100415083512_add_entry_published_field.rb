class AddEntryPublishedField < ActiveRecord::Migration
  def self.up
    add_column :entries, :published, :boolean, :default => 1
  end

  def self.down
    remove_column :entries, :published
  end
end
