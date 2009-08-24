class FeedController < ApplicationController
	session :off
	layout nil
	
	def rss
		headers["Content-Type"] = "text/xml; charset=utf-8" 
		@entries = Entry.find(:all, :order=>'created_at DESC', :limit=>10, :conditions=>["format NOT IN('status')"])
	end

end
