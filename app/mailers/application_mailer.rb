# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptions
  default from: "'#{Setting['club.name_short']} #{Setting['application.name']}' <#{Setting['application.email']}>"
  layout "mailer"

  ActionMailer::Base.register_observer(::MailLoggerObserver)
end
