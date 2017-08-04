FactoryGirl.define do
  factory :presence do
    member nil
    present ""
    on_time 1
    signed_off 1
    remark "MyText"
  end
end
