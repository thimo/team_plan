# == Schema Information
#
# Table name: club_data_logs
#
#  id         :bigint           not null, primary key
#  body       :string
#  level      :integer
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :bigint
#
# Indexes
#
#  index_club_data_logs_on_tenant_id  (tenant_id)
#
FactoryBot.define do
  factory :club_data_log do
    source { 1 }
    level { 1 }
    body { "MyString" }
  end
end
