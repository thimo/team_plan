# == Schema Information
#
# Table name: notes
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  visibility :integer          default("myself")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :bigint
#  team_id    :bigint
#  tenant_id  :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_notes_on_member_id  (member_id)
#  index_notes_on_team_id    (team_id)
#  index_notes_on_tenant_id  (tenant_id)
#  index_notes_on_user_id    (user_id)
#
class Note < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :user
  belongs_to :team
  belongs_to :member, optional: true
  has_paper_trail

  enum visibility: {myself: 0, staff: 1, member: 2}

  validates :title, :body, :visibility, :user, :team, presence: true

  scope :desc, -> { order(created_at: :desc) }

  def self.for_user(scope, team, user)
    # TODO: would prefer to do this through NotePolicy scope, but not sure how to pass team as parameter
    # Own notes
    note_scope = scope.myself.where(user: user)

    # Notes visible for staff (either club or team)
    note_scope = note_scope.or(scope.staff) if user.role?(Role::NOTE_SHOW, team) || user.team_staff_for?(team)

    # Notes written for a member
    note_scope = note_scope.or(scope.member.where(member: user.members))

    note_scope
  end
end
