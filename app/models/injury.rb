# == Schema Information
#
# Table name: injuries
#
#  id         :bigint           not null, primary key
#  body       :text
#  ended_on   :date
#  started_on :date
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :bigint
#  tenant_id  :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_injuries_on_member_id  (member_id)
#  index_injuries_on_tenant_id  (tenant_id)
#  index_injuries_on_user_id    (user_id)
#
class Injury < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :user
  belongs_to :member
  has_many :comments, as: :commentable, dependent: :destroy
  has_paper_trail

  delegate :name, to: :member

  after_save :update_member
  after_destroy :update_member

  validates :started_on, :title, presence: true

  scope :desc, -> { order(created_at: :desc) }
  scope :active, -> { where(ended_on: nil) }

  def self.comment_types
    {"generic" => 0}
  end

  def archived?
    false
  end

  private

  def update_member
    member.update_injured
  end
end
