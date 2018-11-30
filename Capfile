# frozen_string_literal: true

# Load DSL and Setup Up Stages
require "capistrano/setup"
require "capistrano/deploy"

require "capistrano/rails"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano/bundler"
require "capistrano/rvm"

require "capistrano/nginx"
# require "capistrano/upload-config"

require "capistrano/puma"
install_plugin Capistrano::Puma

require "capistrano/puma/nginx"
install_plugin Capistrano::Puma::Nginx

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
