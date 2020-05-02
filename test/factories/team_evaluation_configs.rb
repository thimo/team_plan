# == Schema Information
#
# Table name: team_evaluation_configs
#
#  id         :bigint           not null, primary key
#  config     :jsonb
#  name       :string
#  status     :integer          default("draft")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :bigint
#
# Indexes
#
#  index_team_evaluation_configs_on_tenant_id  (tenant_id)
#
FactoryBot.define do
  factory :team_evaluation_config do
    name { "MyString" }
    status { 1 }
    data { "" }
  end
end
