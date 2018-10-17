# frozen_string_literal: true

class EmailLog < ApplicationRecord
  multi_tenant :tenant
  belongs_to :user

  validates :to, :from, :subject, :body, presence: true
end
