# == Schema Information
#
# Table name: groups
#
#  id                  :bigint           not null, primary key
#  ended_on            :date
#  memberable_via_type :string
#  name                :string
#  started_on          :date
#  status              :integer          default("active")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  tenant_id           :bigint
#
# Indexes
#
#  index_groups_on_tenant_id  (tenant_id)
#
FactoryBot.define do
  factory :group do
    title { "MyString" }
    default { false }
  end
end
