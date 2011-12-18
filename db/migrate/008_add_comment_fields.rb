class AddCommentFields < ActiveRecord::Migration

  class Comment < ActiveRecord::Base; end

  def self.up
    add_column :comments, :website, :string
    add_column :comments, :email, :string
    add_column :comments, :ip, :string

    Comment.reset_column_information
    Comment.find(:all).each do |c|
      if c.href
        field = c.href.include?('@') ? :email : :website
        c[field] = c.href
        c.save
      end
    end
  end

  def self.down
    remove_column :comments, :website
    remove_column :comments, :email
    remove_column :comments, :ip
  end
end
