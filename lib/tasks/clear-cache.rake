namespace :cache do
  desc 'Clear all caches'
  task clear: :environment do
    Rails.cache.clear
    puts "=========== > ALL CACHES BE GONE!"
  end
end
