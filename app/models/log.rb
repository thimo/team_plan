# frozen_string_literal: true

class Log < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :logable, polymorphic: true
  belongs_to :user
end
