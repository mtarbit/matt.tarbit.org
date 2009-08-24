class Comment < ActiveRecord::Base
  acts_as_tree :order => 'created_at', :counter_cache=>true
  belongs_to :entry, :counter_cache=>true
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :content
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
end
