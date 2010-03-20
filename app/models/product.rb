require 'amazon'

class Product < ActiveRecord::Base
  belongs_to :entry
  validates_presence_of :asin
  validates_uniqueness_of :asin

  def associate_url
    # "http://www.amazon.co.uk/dp/#{@asin}/ref=nosim?tag=#{ASSOCIATE_ID}"
    "http://www.amazon.co.uk/dp/#{asin}/?tag=" + SETTINGS['amazon']['associate_id']
  end
  
  def activity
    case group
    when 'Book': 'reading'
    when 'Video Games': 'playing'
    when 'Music': 'listening to'
    when 'DVD': 'watching'
    when 'Electronics': 'using'
    end
  end

  def self.search(search, options={})
    self.request(:search, search, options)
  end

  def self.lookup(search, options={})
    self.request(:lookup, search, options)
  end
  
  def self.request(operation, search, options={})
    raw = options.delete(:Raw)

    amz = Amazon::Product.new(SETTINGS['amazon']['access_key'], SETTINGS['amazon']['secret_key'])
    res = amz.method(operation).call(search, options)

    res = [res] unless res.is_a?(Array)
    res = (raw) ? res : res.collect { |item| self.convert_from_amazon(item) }
    
    (operation == :lookup) ? res[0] : res
  end
  
  def self.search_by_asin(asin)
    self.find_by_asin(asin) || self.create_from_amazon(asin)
  end

  def self.find_images_by_asin(asin)
    images = []
    if product = self.lookup(asin, { :Raw => true })
      ['SmallImage','MediumImage','LargeImage'].each do |image_type|
        img = self.convert_from_amazon_book_image(product[image_type])
        img.image_type = image_type
        images << img
      end
    end
    images
  end
  
  def self.create_from_amazon(asin)
    if item = self.lookup(asin)
      item.save!
      item
    end
  end

  def self.convert_from_amazon(item)
    product = self.new({
      :asin => item['ASIN'],
      :url  => item['DetailPageURL']
    })

	  if item_attr = item['ItemAttributes']
  	  product.title     = item_attr['Title']
  		product.group     = item_attr['ProductGroup']
  		product.creator   = case item_attr['ProductGroup']
  		  when 'Music': "by #{item_attr['Artist']}"
  			when 'Book':  "by #{item_attr['Author'].to_a.to_sentence}"
  		end
	  end

		if item_image = item['LargeImage']
  		product.image     = item_image['URL']
    end
    
    product
  end

  def self.convert_from_amazon_book_image(item)
	  BookImage.new({
  		:url      => item['URL'],
  		:height   => item['Height'],
  		:width    => item['Width']
		})
  end

end
