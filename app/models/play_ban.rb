# == Schema Information
#
# Table name: play_bans
#
#  id            :bigint           not null, primary key
#  body          :text
#  ended_on      :date
#  play_ban_type :integer
#  started_on    :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  member_id     :bigint
#  tenant_id     :bigint
#
# Indexes
#
#  index_play_bans_on_member_id  (member_id)
#  index_play_bans_on_tenant_id  (tenant_id)
#
class PlayBan < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :member
  has_many :comments, as: :commentable, dependent: :destroy

  enum play_ban_type: {contribution: 0}

  scope :by_member, ->(member) { where(member: member) }
  scope :active, -> { start_in_past.end_in_future }
  scope :start_in_past, -> { where("started_on <= ?", Time.zone.today) }
  scope :start_in_future, -> { where("started_on > ?", Time.zone.today) }
  scope :end_in_future, -> { where(ended_on: nil).or(where("ended_on >= ?", Time.zone.today)) }
  scope :end_in_past, -> { where("ended_on < ?", Time.zone.today) }
  scope :order_started_on, -> { order(started_on: :asc) }
  scope :order_ended_on, -> { order(ended_on: :desc) }

  validates :started_on, :play_ban_type, presence: true
end
