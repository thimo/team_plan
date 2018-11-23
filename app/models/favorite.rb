# frozen_string_literal: true

class Favorite < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :favorable, polymorphic: true
  belongs_to :user
end
