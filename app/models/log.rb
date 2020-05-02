# == Schema Information
#
# Table name: logs
#
#  id           :bigint           not null, primary key
#  body         :text
#  logable_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  logable_id   :bigint
#  tenant_id    :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_logs_on_logable_type_and_logable_id  (logable_type,logable_id)
#  index_logs_on_tenant_id                    (tenant_id)
#  index_logs_on_user_id                      (user_id)
#
class Log < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :logable, polymorphic: true
  belongs_to :user
end
