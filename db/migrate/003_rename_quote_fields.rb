class RenameQuoteFields < ActiveRecord::Migration
  def self.up
    # Had to rename quote because of conflict with an AR method name
    # Decided to rename the others while I was at it. The renames must
    # be ordered so that the two :source columns don't exist at once.
    rename_column :quotes, :source, :href
    rename_column :quotes, :attribution, :source
    rename_column :quotes, :quote, :content
  end

  def self.down
    rename_column :quotes, :content, :quote
    rename_column :quotes, :source, :attribution
    rename_column :quotes, :href, :source
  end
end
