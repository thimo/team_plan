# frozen_string_literal: true

class OrgPositionMember < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :org_position
  belongs_to :member
end
