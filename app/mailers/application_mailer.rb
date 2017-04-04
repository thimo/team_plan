class ApplicationMailer < ActionMailer::Base
  default from: '"TeamPlan ESA Rijkerswoerd" <teamplan@defrog.nl>'
  layout 'mailer'

  ActionMailer::Base.register_observer(::MailLoggerObserver)
end
