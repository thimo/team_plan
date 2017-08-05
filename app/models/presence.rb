class Presence < ApplicationRecord
  belongs_to :member
  belongs_to :presentable, polymorphic: true

  scope :asc, -> { includes(:member).order('members.last_name ASC, members.first_name ASC') }
end
