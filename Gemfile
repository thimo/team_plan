source 'https://rubygems.org'

ruby '2.4.0'

gem 'rails', '>= 5.1.0'
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
gem 'faker',                      '>= 1.6.0'
gem 'carrierwave',                '>= 0.10.0'
gem 'carrierwave-imageoptimizer' # also do: brew install optipng jpegoptim (or via 'apt-get' on Ubuntu)
gem 'mini_magick',                '>= 4.3.6'

gem 'rails-i18n'
gem 'kaminari' #,                   '>= 0.16.3'  # Paging
# gem 'kaminari-bootstrap' #,         '>= 3.0.1'   # Bootstrap templates for paging
gem 'bootstrap4-kaminari-views'

# gem 'simple_form' #,                '>= 3.2.0'
gem 'simple_form', github: 'elsurudo/simple_form', branch: 'rails-5.1.0' # Change back to normal simple_form gem after May 10th ??
gem 'country_select'

gem 'breadcrumbs_on_rails' #,       '>= 3.0.1'   # Breadcrumbs
gem 'enum_help' #,                  '>= 0.0.14'
gem 'net-ssh' #,                    '>= 3.0.2'
gem 'figaro' #,                     '>= 1.1.1'
gem 'devise', github: 'plataformatec/devise' # Remove github dependency after May 10th
# gem 'erubis'
gem 'devise-bootstrap-views', git: "https://github.com/hisea/devise-bootstrap-views.git", :branch => 'bootstrap4'
gem 'rails-settings-cached'

gem 'pundit' #,                     '~> 1.1.0'
# gem 'rolify' #,                     '~> 5.0.0'
gem 'awesome_print', require: "awesome_print"
gem 'redcarpet' #,                  '3.3.4' # Markdown parser
gem 'paper_trail'
gem 'rubyzip', '~> 1.1.0'
gem 'axlsx', '2.1.0.pre'
gem 'axlsx_rails'
gem 'pretender'

group :development, :test do
  gem 'byebug', platform: :mri
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
  gem 'minitest'
  gem 'minitest-rails'
end

group :production, :staging do
  gem 'rails_12factor'
  gem 'exception_notification'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
