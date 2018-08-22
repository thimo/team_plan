# frozen_string_literal: true

FactoryBot.define do
  factory :org_position_member do
    org_position nil
    member nil
    name "MyString"
    started_on "2017-12-19"
    ended_on "2017-12-19"
  end
end
