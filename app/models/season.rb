class Season < ApplicationRecord
  has_many :age_groups, dependent: :destroy

  enum status: {draft: 0, active: 1, archived: 2}

  validates_presence_of :name, :status

  scope :asc, -> { order(name: :asc) }
  scope :desc, -> { order(name: :desc) }

end
