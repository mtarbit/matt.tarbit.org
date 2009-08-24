class MergeEntryTypes < ActiveRecord::Migration
  
  class Entry < ActiveRecord::Base
  	belongs_to :content, :polymorphic=>true
  end
  class Link < ActiveRecord::Base; end
  class Post < ActiveRecord::Base; end
  class Quote < ActiveRecord::Base; end

  def self.up
  	add_column :entries, :format, :string
  	add_column :entries, :slug, :string
  	add_column :entries, :title, :string
  	add_column :entries, :content, :text
  	add_column :entries, :url, :string
  	add_column :entries, :extra, :string
		add_index :entries, :slug

		Entry.reset_column_information
		Entry.find(:all).each do |e|
			e.format = e.content_type.to_s.downcase
			case e.format
				when 'post'
					e[:slug] = e.content.title_as_url
					e[:title] = e.content.title
					e[:content] = e.content.content
				when 'link'
					e[:slug] = e.content.title_as_url
					e[:title] = e.content.text
					e[:content] = e.content.description
					e[:url] = e.content.href
					e[:extra] = e.content[:checksum]
				when 'quote'
					e[:slug] = e.content.title_as_url
					e[:title] = e.content.source
					e[:content] = e.content.content
					e[:url] = e.content.href
			end
			e.save
		end
  end

  def self.down
  	remove_column :entries, :format
  	remove_column :entries, :slug
  	remove_column :entries, :title
  	remove_column :entries, :content
  	remove_column :entries, :url
  	remove_column :entries, :extra
  end
end
