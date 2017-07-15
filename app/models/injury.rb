class Injury < ApplicationRecord
  belongs_to :user
  belongs_to :member
  has_paper_trail
end
