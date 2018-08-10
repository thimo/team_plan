# frozen_string_literal: true

class Season < ApplicationRecord
  include Statussable

  has_many :age_groups, dependent: :destroy
  has_paper_trail

  validates :name, :status, :started_on, :ended_on, presence: true

  scope :asc, -> { order(name: :asc) }
  scope :desc, -> { order(name: :desc) }
  scope :active_or_archived, -> { where(status: [Season.statuses[:archived], Season.statuses[:active]]) }

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
    Season.active.first.age_groups.active.each do |age_group|
      new_age_group = AgeGroup.new(age_group.attributes.merge(id: nil, status: :draft, season: self))
      new_age_group.year_of_birth_from += 1 if new_age_group.year_of_birth_from.present?
      new_age_group.year_of_birth_to += 1 if new_age_group.year_of_birth_to.present?
      new_age_group.save
    end
  end

  def self.active_season_for_today
    active.find_by("started_on <= ? AND ended_on >= ?", Time.zone.today, Time.zone.today)
  end
end
