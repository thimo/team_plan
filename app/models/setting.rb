# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { ActsAsTenant.current_tenant }
  acts_as_tenant :tenant
  source Rails.root.join("config", "app.yml")
  namespace Rails.env
end
