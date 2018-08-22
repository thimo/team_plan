# frozen_string_literal: true

class OrgPositionMember < ApplicationRecord
  belongs_to :org_position
  belongs_to :member
end
