# == Schema Information
#
# Table name: email_logs
#
#  id         :bigint           not null, primary key
#  body       :text
#  body_plain :text
#  from       :string
#  subject    :string
#  to         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_email_logs_on_tenant_id  (tenant_id)
#  index_email_logs_on_user_id    (user_id)
#
class EmailLog < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :user, optional: true

  validates :to, :from, :subject, :body, presence: true
end
