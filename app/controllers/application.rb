# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_blog_session_id'
  before_filter :login_from_cookie
  filter_parameter_logging :password

  attr_accessor :wide_layout
  attr_accessor :single_column
  
  def initialize
    @wide_layout = false
    @single_column = false
  end

  def wide_layout?
    @wide_layout ? true : false
  end

  def single_column?
    @single_column ? true : false
  end

  def login_from_cookie
    if cookies[:user]
      session[:user] = User.find(cookies[:user])
    end
  end

  def authenticate
    unless session[:user]
      session[:referrer] = request.request_uri
      redirect_to :controller=>'admin', :action=>'login'
    end
  end

	def entry_options(entry)
		y,m,d = entry.created_at.strftime('%Y %m %d').split
		{:y=>y, :m=>m, :d=>d, :slug=>entry.slug}
  end
	
	def entry_path(*args)
		options = args.last.is_a?(Hash) ? args.pop : {}
		entry_slug_path(entry_options(args.first), options)
	end
	helper_method :entry_path

	def entry_url(*args)
		options = args.last.is_a?(Hash) ? args.pop : {}
		entry_slug_url(entry_options(args.first), options)
	end
	helper_method :entry_url

  def spam_challenge_tokens
    ipaddr = Digest::SHA1.hexdigest(request.env['REMOTE_ADDR'])
    secret = Digest::SHA1.hexdigest(SETTINGS['site_secret'])
    Digest::SHA1.hexdigest(ipaddr + secret).scan(/.{20}/)
  end

end
