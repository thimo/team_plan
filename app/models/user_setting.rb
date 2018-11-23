# frozen_string_literal: true

class UserSetting < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :user
end
