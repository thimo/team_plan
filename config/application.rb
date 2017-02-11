require_relative 'boot'
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TeamPlan
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.default_locale = :nl

    config.autoload_paths += %W(#{config.root}/lib)

    config.to_prepare do
      Devise::SessionsController.layout "devise"
      Devise::Mailer.layout "mailer" # email.haml or email.erb
    end

    config.generators do |g|
      g.javascript_engine :js
    end
  end
end
