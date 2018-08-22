# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# guard 'livereload' do
#   extensions = {
#     css: :css,
#     scss: :css,
#     sass: :css,
#     js: :js,
#     coffee: :js,
#     html: :html,
#     png: :png,
#     gif: :gif,
#     jpg: :jpg,
#     jpeg: :jpeg,
#     # less: :less, # uncomment if you want LESS stylesheets done in browser
#   }
#
#   rails_view_exts = %w(erb haml slim)
#
#   # file types LiveReload may optimize refresh for
#   compiled_exts = extensions.values.uniq
#   watch(%r{public/.+\.(#{compiled_exts * '|'})})
#
#   extensions.each do |ext, type|
#     watch(%r{
#           (?:app|vendor)
#           (?:/assets/\w+/(?<path>[^.]+) # path+base without extension
#            (?<ext>\.#{ext})) # matching extension (must be first encountered)
#           (?:\.\w+|$) # other extensions
#           }x) do |m|
#       path = m[1]
#       "/assets/#{path}.#{type}"
#     end
#   end
#
#   # file needing a full reload of the page anyway
#   watch(%r{app/views/.+\.(#{rails_view_exts * '|'})$})
#   watch(%r{app/helpers/.+\.rb})
#   watch(%r{config/locales/.+\.yml})
# end

notification :terminal_notifier if `uname` =~ /Darwin/

guard :livereload do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
  watch(%r{(app|vendor)(/assets/\w+/(.+)\.(scss))}) { |m| "/assets/#{m[3]}.css" }
end

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

guard :minitest do
  # with Minitest::Unit
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^test/test_helper\.rb$})      { "test" }

  # Uit Vivoforto Portal
  # watch('config/routes.rb')    { integration_tests }
  # watch(%r{^app/models/(.*?)\.rb$}) do |matches|
  #   "test/models/#{matches[1]}_test.rb"
  # end
  # watch(%r{^app/controllers/(.*?)_controller\.rb$}) do |matches|
  #   resource_tests(matches[1])
  # end
  # watch(%r{^app/views/([^/]*?)/.*\.html\.erb$}) do |matches|
  #   ["test/controllers/#{matches[1]}_controller_test.rb"] +
  #   integration_tests(matches[1])
  # end
  # watch(%r{^app/helpers/(.*?)_helper\.rb$}) do |matches|
  #   integration_tests(matches[1])
  # end
  # watch('app/views/layouts/application.html.erb') do
  #   'test/integration/site_layout_test.rb'
  # end
  # watch('app/helpers/sessions_helper.rb') do
  #   integration_tests << 'test/helpers/sessions_helper_test.rb'
  # end
  # watch('app/controllers/sessions_controller.rb') do
  #   ['test/controllers/sessions_controller_test.rb',
  #    'test/integration/users_login_test.rb']
  # end
  # watch('app/controllers/account_activations_controller.rb') do
  #   'test/integration/users_signup_test.rb'
  # end
  # watch(%r{app/views/users/*}) do
  #   resource_tests('users') +
  #   ['test/integration/microposts_interface_test.rb']
  # end
end
