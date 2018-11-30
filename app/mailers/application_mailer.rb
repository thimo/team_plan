# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptions
  layout "mailer"

  ActionMailer::Base.register_observer(::MailLoggerObserver)

  private

    def default_from
      "\"#{ActsAsTenant.current_tenant.settings['club.name_short']} #{Tenant.setting('application.name')}\" <#{Tenant.setting('application.email')}>"
    end
end
