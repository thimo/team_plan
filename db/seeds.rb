User.destroy_all
Season.destroy_all
# Member.destroy_all

seasons = [
  Season.create!(name: "2015 / 2016", status: 2),
  Season.create!(name: "2016 / 2017", status: 1),
  Season.create!(name: "2017 / 2018", status: 0)
]

seasons.each do |season|
  %w[Senioren JO19 JO17 JO15 JO13 JO11 JO9].each do |name|
    AgeGroup.create!(name: name, season: season, gender: "m")
  end
  %w[MO19 MO17 MO15 MO13 MO11].each do |name|
    AgeGroup.create!(name: name, season: season, gender: "v")
  end
end

age_groups = AgeGroup.where(name: "JO11")
age_groups.each do |age_group|
  [*1..13].each do |index|
    Team.create!(name: "JO11-#{index}", age_group: age_group)
  end
end
age_groups = AgeGroup.where(name: "MO11")
age_groups.each do |age_group|
  [*1..2].each do |index|
    Team.create!(name: "MO11-#{index}", age_group: age_group)
  end
end

# player1 = Member.create!({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_number: Faker::Code.ean, association_number: Faker::Code.asin, address: Faker::Address.street_address, city: Faker::Address.city})
# player2 = Member.create!({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_number: Faker::Code.ean, association_number: Faker::Code.asin, address: Faker::Address.street_address, city: Faker::Address.city})
# player3 = Member.create!({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_number: Faker::Code.ean, association_number: Faker::Code.asin, address: Faker::Address.street_address, city: Faker::Address.city})
# coach1 = Member.create!({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_number: Faker::Code.ean, association_number: Faker::Code.asin, address: Faker::Address.street_address, city: Faker::Address.city})

# jo11_8s = Team.where({name: "JO11-8"})
# jo11_8s.each do |jo11_8|
#   TeamMember.create!({team: jo11_8, member: player1, joined_on: Time.zone.local(2016,8,1), role: TeamMember.roles[:player]})
#   TeamMember.create!({team: jo11_8, member: player2, joined_on: Time.zone.local(2016,8,1), role: TeamMember.roles[:player]})
#   TeamMember.create!({team: jo11_8, member: player3, joined_on: Time.zone.local(2016,8,1), role: TeamMember.roles[:player]})
#   TeamMember.create!({team: jo11_8, member: coach1, joined_on: Time.zone.local(2016,8,1), role: TeamMember.roles[:coach]})
# end

User.create!(email: "admin@defrog.nl",
             password: "123456789",
             password_confirmation: "123456789",
             role: 1)
User.create!(email: "member@defrog.nl",
             password: "123456789",
             password_confirmation: "123456789",
             role: 0)
