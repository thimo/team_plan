ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# There's a problem with enabling bootsnap:
# `Cannot define multiple 'included' blocks for a Concern (ActiveSupport::Concern::MultipleIncludedBlocks)`
# Try again later
# require 'bootsnap/setup'
