class Presence < ApplicationRecord
  belongs_to :member
  belongs_to :presentable, polymorphic: true
end
