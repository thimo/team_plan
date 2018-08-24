# frozen_string_literal: true

class EmailLog < ApplicationRecord
  validates :to, :from, :subject, :body, presence: true
  belongs_to :user
end
