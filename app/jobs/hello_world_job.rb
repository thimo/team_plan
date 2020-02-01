class HelloWorldJob < ApplicationJob
  queue_as :default

  def perform
    puts '####################'
    puts '### Hello World! ###'
    puts '####################'
  end
end
