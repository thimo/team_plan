# frozen_string_literal: true

class Injury < ApplicationRecord
  belongs_to :user
  belongs_to :member
  has_many :comments, as: :commentable, dependent: :destroy
  has_paper_trail

  after_save :update_member
  after_destroy :update_member

  validates :started_on, :title, presence: true

  scope :desc, -> { order(created_at: :desc) }
  scope :active, -> { where(ended_on: nil) }

  def self.comment_types
    { "generic" => 0 }
  end

  private

    def update_member
      member.update_injured
    end
end
