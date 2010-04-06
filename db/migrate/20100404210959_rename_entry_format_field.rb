class RenameEntryFormatField < ActiveRecord::Migration
  def self.up
    # Renaming field due to conflict with Kernel.format
    # Only an issue now because of new strictness in AR
    # method_missing over existing private methods.
    rename_column :entries, :format, :variant
  end

  def self.down
    rename_column :entries, :variant, :format
  end
end
