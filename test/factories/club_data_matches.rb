# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    wedstrijddatum { "2017-08-18 21:44:40" }
    wedstrijdcode { 1 }
    wedstrijdnummer { 1 }
    thuisteam { "MyString" }
    uitteam { "MyString" }
    thuisteamclubrelatiecode { "MyString" }
    uitteamclubrelatiecode { "MyString" }
    accommodatie { "MyString" }
    plaats { "MyString" }
    wedstrijd { "MyString" }
    thuisteamid { 1 }
    uitteamid { 1 }
  end
end
