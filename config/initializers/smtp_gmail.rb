opts = {
  :address => "smtp.gmail.com",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true,
  :user_name => SETTINGS['gmail']['username'],
  :password => SETTINGS['gmail']['password']
}

if RUBY_VERSION >= '1.8.7'
  opts[:enable_starttls_auto] = true
else
  opts[:domain] = SETTINGS['domain']
end

ActionMailer::Base.smtp_settings = opts