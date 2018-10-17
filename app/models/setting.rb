# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  multi_tenant :tenant
  source Rails.root.join("config", "app.yml")
  namespace Rails.env
end
