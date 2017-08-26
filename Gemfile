source 'https://rubygems.org'

ruby '2.4.0'

gem 'rails', '~> 5.1.0'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'webpacker'
gem 'webpacker-react'

gem 'slim'
gem 'faker',                      '~> 1.7.0'
gem 'carrierwave',                '~> 1.1.0'
gem 'carrierwave-imageoptimizer' # also do: brew install optipng jpegoptim (or via 'apt-get' on Ubuntu)
gem 'mini_magick',                '~> 4.7.0'

gem 'rails-i18n'
gem 'kaminari',                   '~> 1.0.1'  # Paging
# gem 'kaminari-bootstrap' #,         '~> 3.0.1'   # Bootstrap templates for paging
gem 'bootstrap4-kaminari-views'

gem 'simple_form',                '~> 3.5.0'
gem 'country_select'

gem 'breadcrumbs_on_rails',       '~> 3.0.1'
gem 'enum_help',                  '~> 0.0.17'
gem 'net-ssh',                    '~> 4.1.0'
gem 'figaro',                     '~> 1.1.1'
gem 'devise',                     '~> 4.3.0'
# gem 'erubis'
gem 'devise-bootstrap-views', git: 'https://github.com/hisea/devise-bootstrap-views.git', :branch => 'bootstrap4'
gem 'rails-settings-cached'

gem 'pundit',                     '~> 1.1.0'
# gem 'rolify',                     '~> 5.0.0'
gem 'awesome_print', require: 'awesome_print'
gem 'redcarpet',                  '~> 3.4.0' # Markdown parser
gem 'paper_trail'
gem 'rubyzip',                    '~> 1.1.0'
gem 'axlsx',                      '~> 2.1.0.pre'
gem 'axlsx_rails'
gem 'pretender'
gem 'trix'
gem 'pg_search'
gem 'simple-password-gen'
gem "simple_calendar", "~> 2.0"

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'guard'
  gem 'factory_girl_rails'
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
  gem 'bullet' # help to kill N+1 queries and unused eager loading
  gem 'rack-mini-profiler'
  gem 'guard-livereload', require: false # Adds live-reloading, run with `guard -P livereload`
  gem 'guard-minitest', require: false
  gem 'rack-livereload'
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'
  # gem 'meta_request' # RailsPanel is a Chrome extension for Rails development that will end your tailing of development.log
end

group :test do
  gem 'minitest-reporters'
  # gem 'mini_backtrace'
  gem 'launchy' # For 'save_and_open_page' debugging during testing
  gem 'minitest'
  gem 'minitest-rails'
  gem 'selenium-webdriver'
end

group :production, :staging do
  gem 'rails_12factor'
  gem 'exception_notification'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
