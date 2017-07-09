class Todo < ApplicationRecord
  belongs_to :user
  belongs_to :todoable, polymorphic: true
end
