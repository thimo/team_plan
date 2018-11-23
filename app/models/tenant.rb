# frozen_string_literal: true

class Tenant < ApplicationRecord
  include RailsSettings::Extend
  include Statussable
end
