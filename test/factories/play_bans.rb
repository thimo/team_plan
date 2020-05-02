# == Schema Information
#
# Table name: play_bans
#
#  id            :bigint           not null, primary key
#  body          :text
#  ended_on      :date
#  play_ban_type :integer
#  started_on    :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  member_id     :bigint
#  tenant_id     :bigint
#
# Indexes
#
#  index_play_bans_on_member_id  (member_id)
#  index_play_bans_on_tenant_id  (tenant_id)
#
FactoryBot.define do
  factory :play_ban do
    member { nil }
    starts_at { "2018-09-28" }
    ends_at { "2018-09-28" }
    play_ban_type { 1 }
    body { "MyText" }
  end
end
