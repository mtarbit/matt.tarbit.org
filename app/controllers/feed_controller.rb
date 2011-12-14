class FeedController < ApplicationController
	layout nil
	
	def rss
		headers["Content-Type"] = "text/xml; charset=utf-8" 
		@entries = Entry.published.where(["variant NOT IN ('status')"]).order('created_at DESC').limit(10)
	end

end
