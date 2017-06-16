class Note < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :team, required: true
  belongs_to :member
  has_paper_trail

  enum visibility: { self: 0, staff: 1, member: 2 }

  validates_presence_of :title, :body, :visibility

  scope :desc, -> { order(created_at: :desc) }

  def self.for_user(scope, team, user)
    # TODO would prefer to do this through NotePolicy scope, but not sure how to pass team as parameter
    # Own notes
    note_scope = scope.self.where(user: user)

    # Notes visible for staff (either club or team)
    note_scope = note_scope.or(scope.staff) if user.admin? || user.club_staff? || user.is_team_staff_for?(team)

    # Notes written for a member
    note_scope = note_scope.or(scope.member.where(member: user.members))

    note_scope
  end

end
