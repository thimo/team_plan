# frozen_string_literal: true

class UserSetting < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :user

  serialize :value

  def self.default_for(name)
    case name.to_sym
    when :export_columns
      Member::DEFAULT_COLUMNS
    when :email_separator
      ";"
    when :include_member_comments
      false
    end
  end
end
