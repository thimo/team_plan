# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.5.3"

gem "acts_as_tenant"
gem "jbuilder", "~> 2.5"
# TODO: jquery-rails is included to prevent the following blocking error on deploy, thrown from axlsx_rails:
# "Sprockets::FileNotFound: couldn't find file 'jquery_ujs' with type 'application/javascript'" has been solved
gem "jquery-rails"
gem "pg", "~> 0.18"
gem "puma", "~> 3.0"
gem "rails", "5.2.2"
gem "sassc-rails"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "webpacker", ">= 4.0.x"
gem "webpacker-react"

gem "carrierwave", "~> 1.1.0"
gem "carrierwave-imageoptimizer" # also do: brew install optipng jpegoptim (or via "apt-get" on Ubuntu)
gem "faker"
gem "mini_magick", "~> 4.7.0"
gem "rest-client"
gem "slim-rails"

gem "bootstrap4-kaminari-views"
gem "kaminari"
gem "rails-i18n"

gem "bootstrap_form",             "~> 4.0.0"
gem "breadcrumbs_on_rails",       "~> 3.0.1"
gem "country_select"
gem "devise",                     "~> 4.4.3"
gem "enum_help",                  "~> 0.0.17"
gem "figaro",                     "~> 1.1.1"
gem "net-ssh",                    "~> 4.1.0"
gem "rails-settings-cached"

gem "awesome_print", require: "awesome_print"
gem "paper_trail"
gem "pundit", "~> 1.1.0"
gem "redcarpet", "~> 3.4.0"
gem "rubyzip"

gem "ancestry"
# gem "axlsx",                      "~> 2.1.0.pre"
gem "axlsx", git: "https://github.com/randym/axlsx.git", ref: "c8ac844"
gem "axlsx_rails"
gem "bootsnap", require: false
gem "icalendar", "~> 2.4.1"
gem "pg_search"
gem "pretender"
gem "redis", "~> 4.0"
gem "simple-password-gen"
gem "simple_calendar", "~> 2.0"
gem "trix-rails", require: "trix"

group :development, :test do
  gem "byebug", platform: :mri
  gem "capybara"
  gem "capybara-webkit"
  # gem "pry-rails"
  # gem "pry-byebug"
  gem "factory_bot_rails"
  gem "guard"
  # gem "scout_apm" # Disable to improve loading without internet connction

  gem "capistrano",         require: false
  gem "capistrano-bundler", require: false
  gem "capistrano-rails",   require: false
  gem "capistrano-rvm",     require: false
  gem "capistrano3-nginx",  require: false
  gem "capistrano3-puma",   require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "guard-livereload", require: false # Adds live-reloading, run with `guard -P livereload`
  gem "guard-minitest", require: false
  gem "letter_opener"
  gem "listen", "~> 3.0.5"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  # gem "bullet" # help to kill N+1 queries and unused eager loading
  # gem "rack-mini-profiler"
  gem "rack-livereload"
  # Run `bundle exec erd`
  gem "rails-erd", require: false
  gem "rb-fsevent"
  gem "terminal-notifier-guard"
  gem "web-console"

  gem "brakeman"
  gem "bundler-audit"
  gem "debase"
  gem "debride"
  gem "fasterer"
  gem "rails_best_practices"
  gem "reek"
  gem "rubocop"
  gem "ruby-debug-ide"
end

group :test do
  gem "minitest-reporters"
  # gem "mini_backtrace"
  gem "launchy" # For "save_and_open_page" debugging during testing
  gem "minitest"
  # Disabled to prevent "uninitialized constant Minitest::Rails::TestUnit"
  # gem "minitest-rails"
  gem "selenium-webdriver"
end

group :production, :staging do
  gem "exception_notification"
  gem "rails_12factor"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
