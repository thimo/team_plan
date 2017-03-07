source 'https://rubygems.org'

ruby '2.3.3'

gem 'rails', '>= 5.1.0.beta1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'webpacker'

gem 'slim'
gem 'faker',                      '>= 1.6.0'
gem 'carrierwave',                '>= 0.10.0'
gem 'carrierwave-imageoptimizer' # also do: brew install optipng jpegoptim (or via 'apt-get' on Ubuntu)
gem 'mini_magick',                '>= 4.3.6'

gem 'rails-i18n'
gem 'kaminari' #,                   '>= 0.16.3'  # Paging
#gem 'kaminari-bootstrap' #,         '>= 3.0.1'   # Bootstrap templates for paging

gem 'simple_form' #,                '>= 3.2.0'
gem 'country_select'
# gem 'autosize-rails' #,             '1.18.17' # Auto-resize textarea's

gem 'breadcrumbs_on_rails' #,       '>= 3.0.1'   # Breadcrumbs
gem 'enum_help' #,                  '>= 0.0.14'
gem 'net-ssh' #,                    '>= 3.0.2'
gem 'figaro' #,                     '>= 1.1.1'
gem 'devise'
gem 'devise-bootstrap-views', git: "https://github.com/hisea/devise-bootstrap-views.git", :branch => 'bootstrap4'

gem 'pundit' #,                     '~> 1.1.0'
# gem 'rolify' #,                     '~> 5.0.0'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'awesome_print', require: "awesome_print"
  gem 'pry-byebug'
  gem 'guard', require: false
  gem 'rspec-rails', '~> 3.5'
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
  gem 'meta_request'
  # gem 'better_errors' # https://github.com/charliesome/better_errors - Better error page for Rack apps
  # binding_of_caller is very slow with multiple MB stack trace
  # gem 'binding_of_caller'
  gem 'bullet' # help to kill N+1 queries and unused eager loading
  gem 'rack-mini-profiler'
  gem "guard-livereload", require: false # Adds live-reloading, run with `guard -P livereload`
  gem 'guard-rspec', require: false
  gem "rack-livereload"
  gem "rb-fsevent"
  gem 'spring-commands-rspec'
  gem 'terminal-notifier-guard'
end

group :test do
  gem 'minitest-reporters'
  gem 'mini_backtrace'
  gem 'shoulda-matchers', require: false
  gem 'launchy' # For 'save_and_open_page' debugging during testing
end

group :production, :staging do
  gem 'rails_12factor'
  gem 'exception_notification' # TODO configureren
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
