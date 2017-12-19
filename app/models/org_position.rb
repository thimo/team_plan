class OrgPosition < ApplicationRecord
  has_many :org_position_members
  has_ancestry
end
