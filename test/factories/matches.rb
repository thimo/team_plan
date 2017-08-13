FactoryGirl.define do
  factory :match do
    started_at "2017-08-09 17:29:45"
    remark "MyText"
    team nil
    opponent "MyString"
    home_match false
    goals_self 1
    goals_opponent 1
  end
end
