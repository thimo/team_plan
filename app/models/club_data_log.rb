# frozen_string_literal: true

class ClubDataLog < ApplicationRecord
  validates :level, :source, :body, presence: true

  enum level: { info: 0, debug: 1, warning: 2, error: 3 }
end
