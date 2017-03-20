class FieldPosition < ApplicationRecord
  has_and_belongs_to_many :team_members

  default_scope {order(position: :asc)}
end
