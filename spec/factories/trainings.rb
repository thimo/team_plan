FactoryGirl.define do
  factory :training do
    training_schedule nil
    active false
    starts_at "2017-08-01 16:46:28"
    ends_at "2017-08-01 16:46:28"
    user_modified false
    body "MyText"
    remark "MyText"
  end
end
