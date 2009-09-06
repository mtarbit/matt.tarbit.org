class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors, :order=>'name ASC'
  has_many :book_images, :dependent=>:destroy
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_uniqueness_of :asin

  ASSOCIATE_ID = 'mattarsweb-21'

  def associate_url(tld='co.uk')
    "http://www.amazon.#{tld}/dp/#{self.asin}/?tag=#{ASSOCIATE_ID}"
  end
  
	def authors_as_string=(authors)
    if authors.is_a? String
      authors = authors.split(/\s*,\s*/).map {|a| Author.find_or_initialize_by_name(a) }
		end
    self.authors = authors
  end

  def authors_as_string
    self.authors.map(&:name).join(', ')
  end
  
  def search_for_products
    keywords = (self.isbn.empty?) ? self.title : self.isbn
    products = Product.search(keywords,{ :Raw=>true })
    products = [products] unless products.is_a? Array
    products
  end
  
  def image(image_type)
    self.book_images.select {|img|
      img.image_type == "#{image_type.camelize}Image"
    }.first
  end

end
