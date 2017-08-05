class Presence < ApplicationRecord
  belongs_to :member
  belongs_to :presentable, polymorphic: true

  scope :asc, -> { includes(:member).order('members.last_name ASC, members.first_name ASC') }

  enum on_time: { on_time: 0, a_bit_too_late: 1, much_too_late: 2 }
  enum signed_off: { signed_off_on_time: 0, signed_off_too_late: 1, not_signed_off: 2 }
  
end
