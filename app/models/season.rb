# frozen_string_literal: true

class Season < ApplicationRecord
  include Statussable

  multi_tenant :tenant
  has_many :age_groups, dependent: :destroy
  has_many :teams, through: :age_groups
  has_many :club_data_teams, dependent: :nullify
  has_many :competitions, through: :club_data_teams
  has_many :matches, through: :competitions
  has_paper_trail

  validates :name, :status, :started_on, :ended_on, presence: true

  scope :asc, -> { order(name: :asc) }
  scope :desc, -> { order(name: :desc) }
  scope :active_or_archived, -> { where(status: [Season.statuses[:archived], Season.statuses[:active]]) }
  scope :for_date, ->(date) { where("started_on <= ? AND ended_on >= ?", date, date) }

  def status_children
    # Only propagate status when archiving
    archived? ? age_groups : []
  end

  def previous
    # TODO: properly policy_scope
    self.class.where("created_at < ?", created_at).order(created_at: :asc).last
  end

  def next
    # TODO: properly policy_scope
    self.class.where("created_at > ?", created_at).order(created_at: :asc).first
  end

  def inherit_age_groups
    Season.active.first.age_groups.draft_or_active.each do |age_group|
      new_age_group = AgeGroup.new(age_group.attributes.merge(id: nil, status: :draft, season: self))
      new_age_group.year_of_birth_from += 1 if new_age_group.year_of_birth_from.present?
      new_age_group.year_of_birth_to += 1 if new_age_group.year_of_birth_to.present?
      new_age_group.save

      age_group.group_members.each do |gm|
        GroupMember.create(member: gm.member, group: gm.group, memberable: new_age_group)
      end
    end
  end

  def self.active_season_for_today
    active.for_date(Time.zone.today).first
  end
end
