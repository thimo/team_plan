class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  ActionMailer::Base.register_observer(::MailLoggerObserver)
end
