class Author < ActiveRecord::Base
  has_and_belongs_to_many :books, :order=>'created_at DESC'
  validates_presence_of :name
  validates_uniqueness_of :name
end
