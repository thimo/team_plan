class Presence < ApplicationRecord
  belongs_to :member
  belongs_to :presentable, polymorphic: true
  belongs_to :team

  scope :asc, -> { includes(:member).order('members.last_name ASC, members.first_name ASC') }
  scope :present, -> { where(present: true) }
  scope :not_present, -> { where(present: false) }
  scope :team, -> (team) { where(team: team) }
  scope :for_training,        -> (ids) { where(presentable_type: Training.name).where(presentable_id: ids) }
  scope :for_club_data_match, -> (ids) { where(presentable_type: ClubDataMatch.name).where(presentable_id: ids) }

  enum on_time: { on_time: 0, a_bit_too_late: 1, much_too_late: 2 }
  enum signed_off: { signed_off_on_time: 0, signed_off_too_late: 1, not_signed_off: 2 }

  def set_presentable_user_modified
    if presentable.respond_to?(:user_modified) && presentable.user_modified?
      presentable.update_attributes(user_modified: true) unless presentable.user_modified?
    end
  end

end
