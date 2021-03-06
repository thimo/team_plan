require_relative "boot"

require "csv"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TeamPlan
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    config.i18n.default_locale = :nl
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]
    config.time_zone = "Amsterdam"

    config.autoload_paths += %W[#{config.root}/lib]

    config.to_prepare do
      Devise::SessionsController.layout "devise"
      Devise::Mailer.layout "mailer" # email.haml or email.erb
    end

    config.generators do |generator|
      generator.javascript_engine :js

      generator.javascripts = false
      generator.stylesheets = false
      generator.helper = false
    end

    config.assets.paths << Rails.root.join("vendor/assets/images")
    # A bit dirty, but needed to get @coreui's 'node_modules/*' links working
    config.assets.paths << Rails.root

    config.exceptions_app = routes

    # Enable to prevent loading all helpers all the time
    # config.action_controller.include_all_helpers = false

    console do
      ActiveRecord::Base.connection
    end

    config.active_record.schema_format = :sql
    config.active_job.queue_adapter = :que
    config.action_mailer.deliver_later_queue_name = "default"

    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
