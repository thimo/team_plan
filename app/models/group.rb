class Group < ApplicationRecord
  rolify
  
  has_many :users
end
