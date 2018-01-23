class ClubDataLog < ApplicationRecord
  validates_presence_of :level, :source, :body

  enum level: { info: 0, debug: 1, warning: 2, error: 3 }
end
