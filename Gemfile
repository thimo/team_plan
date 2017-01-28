source 'https://rubygems.org'

ruby '2.3.3'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

gem 'faker',                      '>= 1.6.0'
gem 'carrierwave',                '>= 0.10.0'
gem 'carrierwave-imageoptimizer' # also do: brew install optipng jpegoptim (or via 'apt-get' on Ubuntu)
gem 'mini_magick',                '>= 4.3.6'

#gem 'bootstrap-datepicker-rails'           # Datepicker for Bootstrap
gem 'bootstrap', '~> 4.0.0.alpha6'
source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.4.0'
end

gem 'font-awesome-rails'
gem 'rails-i18n'
gem 'kaminari' #,                   '>= 0.16.3'  # Paging
#gem 'kaminari-bootstrap' #,         '>= 3.0.1'   # Bootstrap templates for paging

gem 'simple_form' #,                '>= 3.2.0'
gem 'country_select'
gem 'autosize-rails' #,             '1.18.17' # Auto-resize textarea's

gem 'breadcrumbs_on_rails' #,       '>= 3.0.1'   # Breadcrumbs in admin
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
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'letter_opener' # TODO configureren ??

  # gem 'capistrano'
  # gem 'capistrano3-puma'
  # gem 'capistrano-rails', require: false
  # gem 'capistrano-bundler', require: false
  # gem 'capistrano-rvm'
  gem 'meta_request'
  gem 'better_errors' # https://github.com/charliesome/better_errors
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'rack-mini-profiler'
end

group :test do
  gem 'minitest-reporters'
  gem 'mini_backtrace'
  gem 'guard'
  gem 'guard-minitest'
end

group :production, :staging do
  gem 'rails_12factor'
  gem 'exception_notification' # TODO configureren
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
