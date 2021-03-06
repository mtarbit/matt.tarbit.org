# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Bring in our own application settings config YAML (leaving it for now)
require 'yaml'
SETTINGS = YAML::load(IO.read("#{RAILS_ROOT}/config/settings.yml"))

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'BlueCloth', :lib => 'bluecloth', :version => '1.0.1'
  config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'
  # config.gem 'openrain-action_mailer_tls', :lib => 'smtp_tls.rb', :source => 'http://gems.github.com'
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # --------------------------------------------------------------------------------
  # Config below was pre-2.3.5 and pre-initializers. May be better placed elsewhere.
  # --------------------------------------------------------------------------------

  # Keep logfiles managable and under control, should limit it to 50 1MB files
  # See: http://blog.caboo.se/articles/2005/12/15/who-said-size-is-not-important
  config.logger = Logger.new(config.log_path, 50, 1024**2)
  
  # Keep cache sweepers and cached pages in their own directories
  # See: http://www.railsenvy.com/2007/2/28/rails-caching-tutorial
  config.load_paths += ["#{RAILS_ROOT}/app/sweepers"]
  # config.action_controller.page_cache_directory = "#{RAILS_ROOT}/public/cache/"
end
