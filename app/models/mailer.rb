require 'smtp_tls'

class Mailer < ActionMailer::Base
  def comment(args)
    @subject    = 'Comment Notification'
    @body       = args
    @recipients = 'mtarbit@gmail.com'
    @from       = 'tarbit.org@googlemail.com'
    @sent_on    = Time.now
    @headers    = {}
  end
end
