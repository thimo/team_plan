User.destroy_all
Season.destroy_all
#YearGroup.destroy_all
#Team.destroy_all
Member.destroy_all
#TeamMember.destroy_all

seasons = [
  Season.create({name: '2015 - 2016', status: 2}),
  Season.create({name: '2016 - 2017', status: 1}),
  Season.create({name: '2017 - 2018', status: 0})
]

seasons.each do |season|
  YearGroup.create({name: "Senioren", season: season})
  YearGroup.create({name: "JO19", season: season})
  YearGroup.create({name: "JO17", season: season})
  YearGroup.create({name: "JO15", season: season})
  YearGroup.create({name: "JO13", season: season})
  YearGroup.create({name: "JO11", season: season})
  YearGroup.create({name: "JO9", season: season})
end

jo11s = YearGroup.where({name: "JO11"})
jo11s.each do |jo11|
  Team.create({name: "ESA JO11-1", year_group: jo11})
  Team.create({name: "ESA JO11-2", year_group: jo11})
  Team.create({name: "ESA JO11-3", year_group: jo11})
  Team.create({name: "ESA JO11-4", year_group: jo11})
  Team.create({name: "ESA JO11-5", year_group: jo11})
  Team.create({name: "ESA JO11-6", year_group: jo11})
  Team.create({name: "ESA JO11-7", year_group: jo11})
  Team.create({name: "ESA JO11-8", year_group: jo11})
  Team.create({name: "ESA JO11-9", year_group: jo11})
  Team.create({name: "ESA JO11-10", year_group: jo11})
  Team.create({name: "ESA JO11-11", year_group: jo11})
  Team.create({name: "ESA JO11-12", year_group: jo11})
  Team.create({name: "ESA JO11-13", year_group: jo11})
end

player1 = Member.create({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_number: Faker::Code.ean, association_number: Faker::Code.asin, address: Faker::Address.street_address, city: Faker::Address.city})
player2 = Member.create({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_number: Faker::Code.ean, association_number: Faker::Code.asin, address: Faker::Address.street_address, city: Faker::Address.city})
player3 = Member.create({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_number: Faker::Code.ean, association_number: Faker::Code.asin, address: Faker::Address.street_address, city: Faker::Address.city})
coach1 = Member.create({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_number: Faker::Code.ean, association_number: Faker::Code.asin, address: Faker::Address.street_address, city: Faker::Address.city})

jo11_8s = Team.where({name: "ESA JO11-8"})
jo11_8s.each do |jo11_8|
  TeamMember.create({team: jo11_8, member: player1, joined_on: Date.new(2016,8,1), role: TeamMember.roles[:player]})
  TeamMember.create({team: jo11_8, member: player2, joined_on: Date.new(2016,8,1), role: TeamMember.roles[:player]})
  TeamMember.create({team: jo11_8, member: player3, joined_on: Date.new(2016,8,1), role: TeamMember.roles[:player]})
  TeamMember.create({team: jo11_8, member: coach1, joined_on: Date.new(2016,8,1), role: TeamMember.roles[:coach]})
end

User.create!(email: 'admin@defrog.nl',
              password: '123456789',
              password_confirmation: '123456789',
              role: 1)
User.create!(email: 'member@defrog.nl',
              password: '123456789',
              password_confirmation: '123456789',
              role: 0)
