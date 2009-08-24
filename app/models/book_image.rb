class BookImage < ActiveRecord::Base
  belongs_to :book
  validates_presence_of :url
  validates_presence_of :height
  validates_presence_of :width
end
