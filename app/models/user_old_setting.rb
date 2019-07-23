# frozen_string_literal: true

class UserOldSetting < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :user
end
