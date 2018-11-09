# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptions
  layout "mailer"

  ActionMailer::Base.register_observer(::MailLoggerObserver)

  private

    def default_from
      "\"#{Setting['club.name_short']} #{Setting['application.name']}\" <#{Setting['application.email']}>"
    end
end
