# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "'#{Setting['application.name']} #{Setting['club.name']}' <teamplan@defrog.nl>"
  layout "mailer"

  ActionMailer::Base.register_observer(::MailLoggerObserver)

  def default_url_options
    {
      host: Setting["club.hostname"],
      protocol: "https"
    }
  end

  def asset_host
    "#{default_url_options[:protocol]}://#{default_url_options[:host]}"
  end
end
