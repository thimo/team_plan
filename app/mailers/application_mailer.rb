class ApplicationMailer < ActionMailer::Base
  default from: '"TeamPlan" <teamplan@esa-rijkerswoerd.nl>'
  layout 'mailer'

  ActionMailer::Base.register_observer(::MailLoggerObserver)
end
