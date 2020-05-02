# == Schema Information
#
# Table name: club_data_logs
#
#  id         :bigint           not null, primary key
#  body       :string
#  level      :integer
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :bigint
#
# Indexes
#
#  index_club_data_logs_on_tenant_id  (tenant_id)
#
class ClubDataLog < ApplicationRecord
  acts_as_tenant :tenant
  validates :level, :source, :body, presence: true

  enum level: { info: 0, debug: 1, warning: 2, error: 3 }

  scope :desc, -> { order(id: :desc) }
end
