module Presentable
  extend ActiveSupport::Concern

  included do
    has_many :presences, as: :presentable, dependent: :destroy
  end

  def find_or_create_presences
    if presences.empty?
      teams.each do |team|
        team.team_members.player.active.asc.each do |team_member|
          presences.create(member: team_member.member, team: team)
        end
      end
    end

    presences
  end

  private

  module ClassMethods
  end

end
