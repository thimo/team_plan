class Note < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :team, required: true
  belongs_to :member
  has_paper_trail

  enum visibility: { self: 0, staff: 1, member: 2 }

  validates_presence_of :title, :body

  scope :desc, -> { order(created_at: :desc) }
  # scope :own, -> (user) { where(visibility: Note.visibilities[:self], user: user) }

  def for_user(scope, team, user)
    note_scope = scope.self.where(user: user)

    note_scope = note_scope.or(scope.staff) if user.club_staff? || user.is_team_staff_for?(team)

    note_scope = note_scope.or(scope.member.where(member: user.members))

  end

end
