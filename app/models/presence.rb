# == Schema Information
#
# Table name: presences
#
#  id               :bigint           not null, primary key
#  is_present       :boolean          default(TRUE)
#  minutes_played   :integer
#  on_time          :integer          default("on_time")
#  own_player       :boolean          default(TRUE)
#  presentable_type :string
#  remark           :text
#  signed_off       :integer          default("signed_off_on_time")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  member_id        :bigint
#  presentable_id   :bigint
#  team_id          :bigint
#  tenant_id        :bigint
#
# Indexes
#
#  index_presences_on_member_id                            (member_id)
#  index_presences_on_presentable_type_and_presentable_id  (presentable_type,presentable_id)
#  index_presences_on_team_id                              (team_id)
#  index_presences_on_tenant_id                            (tenant_id)
#
class Presence < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :member
  belongs_to :presentable, polymorphic: true, touch: true
  belongs_to :team

  scope :asc, -> { includes(:member).order("members.last_name ASC, members.first_name ASC") }
  scope :present, -> { where(is_present: true) }
  scope :not_present, -> { where(is_present: false) }
  scope :team, ->(team) { where(team: team) }
  scope :for_training, ->(ids) { where(presentable_type: Training.name).where(presentable_id: ids) }
  scope :for_match, ->(ids) { where(presentable_type: Match.name).where(presentable_id: ids) }
  scope :own_player, -> { where(own_player: true) }
  scope :not_own_player, -> { where(own_player: false) }

  enum on_time: { on_time: 0, a_bit_too_late: 1, much_too_late: 2 }
  enum signed_off: { signed_off_on_time: 0, signed_off_too_late: 1, not_signed_off: 2 }
end
