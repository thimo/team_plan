FactoryGirl.define do
  factory :member do
    first_name { Faker::Name.first_name }
    middle_name {  }
    last_name { Faker::Name.last_name }
    born_on {  }
    address {  }
    zipcode {  }
    city {  }
    country {  }
    phone {  }
    phone2 {  }
    email { Faker::Internet.email }
    email2 { Faker::Internet.email }
    gender {  }
    member_number {  }
    association_number {  }
    active {  }
    created_at {  }
    updated_at {  }
    user_id {  }
    email_2 {  }
    phone_2 {  }
    initials {  }
    conduct_number {  }
    sport_category {  }
    imported_at {  }
    status {  }
    full_name_2 {  }
    place_of_birth {  }
    country_of_birth {  }
    nationality {  }
    nationality_2 {  }
    id_type {  }
    id_number {  }
    lasts_change_at {  }
    privacy_level {  }
    street {  }
    house_number {  }
    house_number_addition {  }
    phone_home {  }
    contact_via_parent {  }
    phone_parent {  }
    phone_parent_2 {  }
    email_parent {  }
    email_parent_2 {  }
    bank_account_type {  }
    bank_account_number {  }
    bank_bic {  }
    bank_authorization {  }
    contribution_category {  }
    registered_at {  }
    deregistered_at {  }
    member_since {  }
    age_category {  }
    local_teams {  }
    club_sports {  }
    association_sports {  }
    person_type {  }
  end
end
