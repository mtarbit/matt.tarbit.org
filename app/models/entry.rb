class Entry < ActiveRecord::Base
  has_many :threads, { :class_name=>'Comment', :conditions=>'parent_id IS NULL', :order=>'created_at ASC' }
  has_many :comments, :order => 'created_at', :dependent => :destroy
  has_and_belongs_to_many :tags, :order => 'name'
  has_one :product, :dependent=>:destroy

	validates_presence_of :title
	validates_presence_of :slug
	# validates_uniqueness_of :slug

  @@VARIANTS = ['link','post','review','quote','status']

  def self.variants
    @@VARIANTS
  end
	
  def tags_as_string=(tags)
    if tags.is_a? String
      tags = tags.split.map {|t| Tag.find_or_initialize_by_name(t) }
		end
    self.tags = tags
  end

  def tags_as_string
    self.tags.map(&:name).join(' ')
  end

	def generate_slug
		str = self.title.downcase.gsub(/[^a-z0-9._ ]+/,'').gsub(/ +/,'-')
		str = str.split(/-/)[0,3].join('-') if self.variant != 'post'
		self.slug = str
	end

  def longform?
    ['post','review'].include? self.variant
  end
		
	def page_title
		case self.variant
			when 'post': self.title
			when 'link': "Bookmark for \"#{self.title}\""
			when 'quote': "A quote from #{self.title}"
			when 'review': "I've been #{self.product.activity}: #{self.product.title}"
			when 'status': "#{self.title}: \"#{self.content}\""
		end
	end

  def status_url
    "http://twitter.com/mtarbit/status/#{self.url}" if self.variant == 'status'
  end

  def find_next
    self.class.find(:first, :conditions=>['created_at > ?', self.created_at], :order=>'created_at ASC')
  end

  def find_prev
    self.class.find(:first, :conditions=>['created_at < ?', self.created_at], :order=>'created_at DESC')
  end

  def self.counts_by_date
    sql = "SELECT
            DATE_FORMAT(created_at,'%Y') AS y, 
            DATE_FORMAT(created_at,'%m') AS m, 
            DATE_FORMAT(created_at,'%d') AS d, 
            COUNT(*) AS n 
          FROM 
            entries 
          GROUP BY y,m,d 
          ORDER BY y,m,d ASC"
    res = ActiveRecord::Base.connection.select_all(sql)

    dates = {}

    for r in res
      y = r['y'].to_i
      m = r['m'].to_i
      d = r['d'].to_i
      n = r['n'].to_i

      dates[y] ||= {}
      dates[y][m] ||= {}
      dates[y][m][d] ||= n
    end
    
    dates
  end
  
  def self.find_by_slug(y,m,d, slug)
    entries = self.find_by_date(y,m,d, slug)
		(entries.length < 2) ? entries.first : entries
  end

  def self.find_by_date(y,m,d=nil,slug=nil)
    y,m,d = [y,m,d].map{|v| v.to_i if v }

		# rescue ArgumentErrors from out of range values
		# rescue NoMethodErrors from attempting addition on nilClass
		t1 = Time.local(y,m,d)
		t2 = 
		begin			Time.local(y,m,d+1) 
		rescue: 
			begin 	Time.local(y,m+1,1) 
			rescue: Time.local(y+1,1,1) 
			end
		end

		conds = {}
		conds[:created_at] = t1..t2
		conds[:slug] = slug if slug

		entries = find(:all, :include=>[:comments,:tags], :conditions=>conds, :order=>"entries.created_at DESC")
  end

  def self.find_by_words(words)
    sql = []; arg = []
    sql_words = words.map {|w|
      # escape special chars to hide them from MySQL's RLIKE
      w = w.gsub(/([.\[\]*^\$])/, '\\\\\1')
      # wrap with MySQL RLIKE word boundary character classes
      w = '[[:<:]]'+w+'[[:>:]]'
    }
    sql_words.each {|w|
      sql << "(entries.title RLIKE ? OR entries.content RLIKE ?)"
      arg += [w,w]
    }
    conds = [sql.join(' AND ')] + arg
    entries = find(:all, :include=>[:comments], :conditions=>conds, :order=>"entries.created_at DESC")
  end

  def self.create_from_twitter(item)
    item = self.convert_from_twitter(item)
    tweet = self.find_by_url(item['url']) || self.new
		tweet.attributes = item
		if tweet.changed?
  		logger.info("Changed attributes: #{tweet.changes.inspect}")
  		# Only save if the attributes have changed. Otherwise
  		# we'll trigger the cache sweeper for every sync
  		tweet.generate_slug
  		tweet.save!
  	end
  end

  def self.convert_from_twitter(item)
    attrs = {
			'variant' => 'status',
      'created_at' => Time.parse(item.created_at),
      'url' => item.id,
      'title' => "Status #{item.id}",
      'content' => item.text,
      'extra' => item.user.profile_image_url
    }
  end

  def self.create_from_delicious(item)
    item = self.convert_from_delicious(item)
    link = self.find_by_url(item['url']) || self.new
		link.attributes = item
		if link.changed?
  		logger.info("Changed attributes: #{link.changes.inspect}")
  		# Only save if the attributes have changed. Otherwise
  		# we'll trigger the cache sweeper for every link sync
  		link.generate_slug
  		link.save!
  	end
  end

  def self.convert_from_delicious(item)
    attrs = {
			'variant' => 'link',
      'created_at' => item['time'],
      'url' => item['href'],
      'title' => item['description'],
      'content' => item['extended'],
      'extra' => item['hash']
    }
		attrs['tags_as_string'] = item['tags'].join(' ') if item['tags']
		attrs
  end

end
