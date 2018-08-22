# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :member
end
