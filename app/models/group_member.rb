# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :member
  belongs_to :memberable, polymorphic: true, optional: true
end
