FactoryGirl.define do
  factory :note do
    title "MyString"
    body "MyText"
    user nil
    team nil
    member nil
    visibility 1
  end
end
