FactoryBot.define do
  factory :play_ban do
    member { nil }
    starts_at { "2018-09-28" }
    ends_at { "2018-09-28" }
    play_ban_type { 1 }
    body { "MyText" }
  end
end
