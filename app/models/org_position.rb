class OrgPosition < ApplicationRecord
  has_many :org_position_members
  has_ancestry

  enum position_type: { role: 0, committee: 1, working_group: 2 }

  validates_presence_of :name, :started_on
end
