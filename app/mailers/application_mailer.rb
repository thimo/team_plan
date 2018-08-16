class ApplicationMailer < ActionMailer::Base
  default from: "'#{Setting['application.name']} #{Setting['club.name']}' <teamplan@defrog.nl>"
  layout 'mailer'

  ActionMailer::Base.register_observer(::MailLoggerObserver)
end
