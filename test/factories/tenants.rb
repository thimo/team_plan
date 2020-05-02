# == Schema Information
#
# Table name: tenants
#
#  id         :bigint           not null, primary key
#  domain     :string
#  host       :string
#  name       :string
#  status     :integer          default("active")
#  subdomain  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :tenant do
    name { "MyString" }
    subdomain { "MyString" }
    domain { "MyString" }
  end
end
