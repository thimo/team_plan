# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config", "app.yml")
  namespace Rails.env

  def self.for_current_tenant(var:)
    find_or_initialize_by(thing: ActsAsTenant.current_tenant, var: var) do |setting|
      setting.value = ActsAsTenant.current_tenant&.settings&.send(var)
    end
  end
end
