# == Schema Information
#
# Table name: favorites
#
#  id             :integer          not null, primary key
#  favorable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  favorable_id   :integer
#  tenant_id      :bigint
#  user_id        :integer
#
# Indexes
#
#  index_favorites_on_favorable_type_and_favorable_id  (favorable_type,favorable_id)
#  index_favorites_on_tenant_id                        (tenant_id)
#  index_favorites_on_user_id                          (user_id)
#
class Favorite < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :favorable, polymorphic: true
  belongs_to :user
end
