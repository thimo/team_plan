# == Schema Information
#
# Table name: soccer_fields
#
#  id         :bigint           not null, primary key
#  match      :boolean          default(TRUE)
#  name       :string
#  training   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :bigint
#
# Indexes
#
#  index_soccer_fields_on_tenant_id  (tenant_id)
#
class SoccerField < ApplicationRecord
  acts_as_tenant :tenant
  has_many :training_schedules
  has_paper_trail

  scope :asc, -> { order(:name) }
  scope :training, -> { where(training: true) }
end
