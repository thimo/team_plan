# frozen_string_literal: true

class UserSetting < ApplicationRecord
  multi_tenant :tenant
  belongs_to :user
end
