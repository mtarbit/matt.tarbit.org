# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :login_from_cookie

  attr_accessor :wide_layout
  attr_accessor :single_column

  # Need to replace this with something suitable.
  # rescue_from Exception, :with => :render_error
  # rescue_from ActiveRecord::RecordNotFound :with => :render_not_found

  def initialize
    @wide_layout = false
    @single_column = false
    super
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
		entry_slug_path(entry_options(args.first)) # , options)
	end
	helper_method :entry_path

	def entry_url(*args)
		options = args.last.is_a?(Hash) ? args.pop : {}
		entry_slug_url(entry_options(args.first)) # , options)
	end
	helper_method :entry_url

  def spam_challenge_tokens
    ipaddr = Digest::SHA1.hexdigest(request.env['REMOTE_ADDR'])
    secret = Digest::SHA1.hexdigest(SETTINGS['site_secret'])
    Digest::SHA1.hexdigest(ipaddr + secret).scan(/.{20}/)
  end

protected

  def render_error(exception=nil)
    log_error(exception) if exception
    render_optional_error_file(:internal_server_error)
  end

  def render_not_found(exception=nil)
    log_error(exception) if exception
    render_optional_error_file(:not_found)
  end

  def render_optional_error_file(status_code)
    status = interpret_status(status_code)
    render :template => "/errors/#{status[0,3]}.html.erb", :status => status, :layout => "application.html.erb"
  end

end
