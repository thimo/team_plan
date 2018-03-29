source 'https://rubygems.org'

ruby '2.5.1'

gem 'rails', '~> 5.2.0-pre'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'webpacker'
gem 'webpacker-react'

gem 'less-rails', '~> 3.0.0'
gem 'therubyracer'

gem 'slim-rails'
gem 'faker'
gem 'carrierwave',                '~> 1.1.0'
gem 'carrierwave-imageoptimizer' # also do: brew install optipng jpegoptim (or via 'apt-get' on Ubuntu)
gem 'mini_magick',                '~> 4.7.0'

gem 'rails-i18n'
gem 'kaminari'
gem 'bootstrap4-kaminari-views'

gem 'simple_form',                '~> 3.5.0'
gem 'bootstrap_form', git: 'https://github.com/bootstrap-ruby/bootstrap_form.git', branch: 'master'
gem 'country_select'

gem 'breadcrumbs_on_rails',       '~> 3.0.1'
gem 'enum_help',                  '~> 0.0.17'
gem 'net-ssh',                    '~> 4.1.0'
gem 'figaro',                     '~> 1.1.1'
gem 'devise',                     '4.4.1' # 4.4.2 causes 'Devise.secret_key was not set. Please add the following to your Devise initializer'
# gem 'devise-bootstrap-views', git: 'https://github.com/hisea/devise-bootstrap-views.git', :branch => 'bootstrap4'
gem 'rails-settings-cached'

gem 'pundit',                     '~> 1.1.0'
gem 'rolify'
gem 'awesome_print', require: 'awesome_print'
gem 'redcarpet',                  '~> 3.4.0' # Markdown parser
gem 'paper_trail'
gem 'rubyzip'
# gem 'axlsx',                      '~> 2.1.0.pre'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'
gem 'pretender'
gem 'trix', git: 'https://github.com/bcoia/trix.git' # Fix for 'wrong number of arguments' - https://github.com/maclover7/trix/issues/54
gem 'pg_search'
gem 'simple-password-gen'
gem 'simple_calendar',            '~> 2.0'
gem 'icalendar',                  '~> 2.4.1'
gem 'bootsnap', require: false
gem 'ancestry'
gem 'redis', '~> 4.0'

group :development, :test do
  gem 'byebug', platform: :mri
  # gem 'pry-rails'
  # gem 'pry-byebug'
  gem 'scout_apm' # Disabled to improve loading without internet connction
  gem 'guard'
  gem 'factory_bot_rails'
  gem 'capybara'
  gem 'capybara-webkit'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'letter_opener'
  # gem 'bullet' # help to kill N+1 queries and unused eager loading
  # gem 'rack-mini-profiler'
  gem 'guard-livereload', require: false # Adds live-reloading, run with `guard -P livereload`
  gem 'guard-minitest', require: false
  gem 'rack-livereload'
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'
  gem 'rails-erd', require: false
end

group :test do
  gem 'minitest-reporters'
  # gem 'mini_backtrace'
  gem 'launchy' # For 'save_and_open_page' debugging during testing
  gem 'minitest'
  # Disabled to prevent 'uninitialized constant Minitest::Rails::TestUnit'
  # gem 'minitest-rails'
  gem 'selenium-webdriver'
end

group :production, :staging do
  gem 'rails_12factor'
  gem 'exception_notification'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
