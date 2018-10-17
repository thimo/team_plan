# frozen_string_literal: true

class Log < ApplicationRecord
  multi_tenant :tenant
  belongs_to :logable, polymorphic: true
  belongs_to :user
end
