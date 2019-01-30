# frozen_string_literal: true

FactoryBot.define do
  factory :club_data_log do
    source { 1 }
    level { 1 }
    body { "MyString" }
  end
end
