class Note < ApplicationRecord
  belongs_to :user
  belongs_to :team
  belongs_to :member
end
