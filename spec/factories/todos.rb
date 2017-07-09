FactoryGirl.define do
  factory :todo do
    user nil
    body "MyText"
    waiting false
    finished false
    todoable nil
  end
end
