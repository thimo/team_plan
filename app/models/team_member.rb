class TeamMember < ApplicationRecord
  FIELD_POSITION_OPTIONS = {
      "Aanval" => ["linksbuiten", "spits", "rechtsbuiten"],
      "Middenveld" => ["linkshalf", "centrale middenvelder", "rechtshalf"],
      "Verdediging" => ["linksachter", "voorstopper", "rechtsachter", "laatste man", "keeper"],
      "As" => ["linker as", "centrale as", "rechter as"],
      "Linie" => ["aanvaller", "middenvelder", "verdediger"],
      "Overig" => ["geen voorkeur"]
    }
  PREFERED_FOOT_OPTIONS = %w(rechtsbenig linksbenig tweebenig onbekend)

  before_save :inherit_fields

  belongs_to :team
  belongs_to :member, required: true
  has_many :player_evaluations, dependent: :destroy

  enum role: {player: 0, coach: 1, trainer: 2, team_parent: 3}

  validates_presence_of :team, :member, :role
  validates :role, :uniqueness => {scope: [:team, :member]}

  scope :staff, -> {where.not(role: TeamMember.roles[:player]).includes(:member)}
  scope :asc, -> {includes(:member).order('members.last_name ASC, members.first_name ASC').includes(:team)}
  scope :includes_parents, -> {includes(:team).includes(team: :age_group).includes(team: {age_group: :season})}

  def age_group
    team.age_group
  end

  def season
    age_group.season
  end

  def draft?
    team.age_group.season.draft?
  end

  def active?
    team.age_group.season.active?
  end

  def archived?
    team.age_group.season.archived?
  end

  private

    def inherit_fields
      if member.active_team_member.present?
        self.prefered_foot = member.active_team_member.prefered_foot
        self.field_position = member.active_team_member.field_position
      end
    end
end
