# == Schema Information
#
# Table name: user_settings
#
#  id         :bigint           not null, primary key
#  name       :string
#  value      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_user_settings_on_tenant_id         (tenant_id)
#  index_user_settings_on_user_id           (user_id)
#  index_user_settings_on_user_id_and_name  (user_id,name) UNIQUE
#
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
    when :sportlink_members_encoding
      "utf-8"
    end
  end
end
