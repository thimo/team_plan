# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptions
  layout "mailer"

  ActionMailer::Base.register_observer(::MailLoggerObserver)

  private

    def default_from
      "\"#{ActsAsTenant.current_tenant.settings['club.name_short']} #{ActsAsTenant.current_tenant.settings['application.name']}\" <#{ActsAsTenant.current_tenant.settings['application.email']}>"
    end
end
