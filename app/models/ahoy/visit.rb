# frozen_string_literal: true

class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"
  acts_as_tenant :tenant

  has_many :events, class_name: "Ahoy::Event", dependent: :destroy
  belongs_to :user, optional: true
end
