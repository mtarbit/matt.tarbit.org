class CommentChildrenCount < ActiveRecord::Migration
  def self.up
    add_column :comments, :children_count, :integer, :default=>0

    # I can't actually get this to work, fetching the children
    # and then setting the children_count needs to be done in 
    # 2 steps or the SELECT is short-circuited, this seems to be
    # run in a COMMIT block or something so it's not working.
    
	  # Run this in script/console instead and it'll work fine.
	
		comments = Comment.find(:all)
    comments.each {|c| c.children }
		comments.each {|c| c.children_count = c.children.size; c.save! }
  end

  def self.down
    remove_column :comments, :children_count
  end
end

