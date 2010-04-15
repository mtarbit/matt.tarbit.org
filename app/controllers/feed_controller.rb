class FeedController < ApplicationController
	session :off
	layout nil
	
	def rss
		headers["Content-Type"] = "text/xml; charset=utf-8" 
		@entries = Entry.published.find(:all, :order=>'created_at DESC', :limit=>10, :conditions=>["variant NOT IN('status')"])
	end

end
