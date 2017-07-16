class Injury < ApplicationRecord
  belongs_to :user
  belongs_to :member
  has_paper_trail

  after_save :update_member
  after_destroy :update_member

  validates_presence_of :started_on, :title

  scope :desc, -> { order(created_at: :desc) }
  scope :active, -> { where(ended_on: nil) }

  private

    def update_member
      member.update_injured
    end

end
