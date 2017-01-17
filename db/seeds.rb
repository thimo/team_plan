User.destroy_all
Season.destroy_all
#YearGroup.destroy_all
#Team.destroy_all
Member.destroy_all
#TeamMember.destroy_all

season = Season.create({name: '2016 - 2017', active: true})
jo19 = YearGroup.create({name: "JO19", season: season})
jo17 = YearGroup.create({name: "JO17", season: season})
jo15 = YearGroup.create({name: "JO15", season: season})
jo13 = YearGroup.create({name: "JO13", season: season})
jo11 = YearGroup.create({name: "JO11", season: season})
jo9 = YearGroup.create({name: "JO9", season: season})

jo11_1 = Team.create({name: "ESA JO11-1", year_group: jo11})
jo11_2 = Team.create({name: "ESA JO11-2", year_group: jo11})
jo11_3 = Team.create({name: "ESA JO11-3", year_group: jo11})
jo11_4 = Team.create({name: "ESA JO11-4", year_group: jo11})
jo11_5 = Team.create({name: "ESA JO11-5", year_group: jo11})
jo11_6 = Team.create({name: "ESA JO11-6", year_group: jo11})
jo11_7 = Team.create({name: "ESA JO11-7", year_group: jo11})
jo11_8 = Team.create({name: "ESA JO11-8", year_group: jo11})
jo11_9 = Team.create({name: "ESA JO11-9", year_group: jo11})
jo11_10 = Team.create({name: "ESA JO11-10", year_group: jo11})
jo11_11 = Team.create({name: "ESA JO11-11", year_group: jo11})
jo11_12 = Team.create({name: "ESA JO11-12", year_group: jo11})
jo11_13 = Team.create({name: "ESA JO11-13", year_group: jo11})

player1 = Member.create({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_id: Faker::Code.ean, association_id: Faker::Code.asin})
player2 = Member.create({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_id: Faker::Code.ean, association_id: Faker::Code.asin})
player3 = Member.create({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_id: Faker::Code.ean, association_id: Faker::Code.asin})
coach1 = Member.create({first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::PhoneNumber.phone_number, member_id: Faker::Code.ean, association_id: Faker::Code.asin})

TeamMember.create({team: jo11_8, member: player1, joined_on: Date.new(2016,8,1), role: TeamMember.roles[:role_player]})
TeamMember.create({team: jo11_8, member: player2, joined_on: Date.new(2016,8,1), role: TeamMember.roles[:role_player]})
TeamMember.create({team: jo11_8, member: player3, joined_on: Date.new(2016,8,1), role: TeamMember.roles[:role_player]})
TeamMember.create({team: jo11_8, member: coach1, joined_on: Date.new(2016,8,1), role: TeamMember.roles[:role_coach]})

User.create!(email: 'admin@defrog.nl',
             password: '123456789',
             password_confirmation: '123456789')
