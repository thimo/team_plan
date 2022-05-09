source "https://rubygems.org"

ruby "2.7.3"

gem "acts_as_tenant"
gem "jbuilder", "~> 2.11"
gem "pg", "~> 1.3"
gem "puma", "~> 5.6"
gem "que", "~> 1.0.0.beta4"
gem "que-scheduler"
gem "que-web"
gem "rails", "~> 6.1.5"
gem "rails-i18n"
gem "turbolinks", "~> 5"
gem "webpacker", "~> 6.0.0.rc.5"

gem "carrierwave", "~> 2.2.2"
gem "carrierwave-imageoptimizer" # also do: brew install optipng jpegoptim (or via "apt-get" on Ubuntu)
gem "faker"
gem "mini_magick"
gem "rest-client"
gem "slim-rails"

gem "bootstrap4-kaminari-views"
gem "bootstrap_form", "~> 4.5.0"
gem "breadcrumbs_on_rails", "~> 4.1.0"
gem "country_select"
gem "devise", "~> 4.8"
gem "enum_help", "~> 0.0.19"
gem "figaro", "~> 1.2.0"
gem "inline_svg"
gem "kaminari"
gem "net-ssh", "~> 6.1.0"

gem "awesome_print", require: "awesome_print"
gem "paper_trail"
gem "pundit"
gem "redcarpet", "~> 3.5.1"
gem "rubyzip"

gem "bootsnap", require: false
gem "caxlsx", "~> 3.2"
gem "caxlsx_rails"
gem "icalendar", "~> 2.7.1"
gem "pg_search", "~> 2.3.6"
gem "pretender"
gem "redis", "~> 4.6"
gem "simple-password-gen"
gem "simple_calendar", "~> 2.4"

group :development, :test do
  gem "byebug", platform: :mri
  gem "capybara"
  gem "selenium-webdriver"
  gem "factory_bot_rails"
  gem "guard"
  gem "scout_apm" # Disable to improve loading without internet connction
  gem "standard"
end

group :development do
  gem "annotate"
  gem "bullet" # help to kill N+1 queries and unused eager loading
  gem "derailed_benchmarks" # bundle exec derailed bundle:mem
  gem "guard-livereload", require: false # Adds live-reloading, run with `guard -P livereload`
  gem "guard-minitest", require: false
  gem "letter_opener"
  gem "listen"
  gem "pry-rails"
  gem "rack-livereload"
  gem "rails-erd", require: false # Run `bundle exec erd`
  gem "rb-fsevent"
  gem "terminal-notifier-guard"
  gem "web-console"

  gem "reek"
  gem "solargraph"
  gem "stackprof"
end

group :test do
  gem "launchy" # For "save_and_open_page" debugging during testing
  gem "minitest"
  gem "minitest-reporters"
  # Disabled to prevent "uninitialized constant Minitest::Rails::TestUnit"
  # gem "minitest-rails"
end

group :production, :staging do
  gem "exception_notification"
  gem "rails_12factor"
end
