class EmailLog < ApplicationRecord
  validates_presence_of :to, :from, :subject, :body
  belongs_to :user
end
