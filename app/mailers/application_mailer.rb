# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptions
  layout "mailer"

  before_action { @salutation_names = Tenant.setting("application_contact_name") }

  ActionMailer::Base.register_observer(::MailLoggerObserver)

  private

    def default_from
      "\"#{Tenant.setting('club_name_short')} #{Tenant.setting('application_name')}\" <#{Tenant.setting('application_email')}>"
    end
end
