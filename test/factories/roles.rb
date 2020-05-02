# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  body          :text
#  description   :text
#  name          :string
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :bigint
#  tenant_id     :bigint
#
# Indexes
#
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#  index_roles_on_resource_type_and_resource_id           (resource_type,resource_id)
#  index_roles_on_tenant_id                               (tenant_id)
#
FactoryBot.define do
  factory :role do
  end
end
