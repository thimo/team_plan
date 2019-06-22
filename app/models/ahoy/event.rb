# frozen_string_literal: true

class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  acts_as_tenant :tenant
  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true
end
