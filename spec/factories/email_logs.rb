FactoryGirl.define do
  factory :email_log do
    from "MyString"
    to "MyString"
    subject "MyString"
    body "MyText"
    body_plain "MyText"
    user nil
  end
end
