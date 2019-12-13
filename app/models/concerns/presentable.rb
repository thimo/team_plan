# frozen_string_literal: true

# Extends a model to allow setting presence to members
module Presentable
  extend ActiveSupport::Concern

  included do
    has_many :presences, as: :presentable, dependent: :destroy
  end

  def find_or_create_presences(team = nil)
    team ||= respond_to?(:teams) ? teams.first : self.team

    return Presence.none if team.archived?

    if presences.team(team).empty?
      # Add presences for all local teams (can be two local teams per match)
      team.team_members.player.active.asc.each do |team_member|
        presence = presences.create(member: team_member.member, team: team)

        if team_member.member.injured?
          presence.update(is_present: false, remark: "Blessure (#{team_member.member.injuries.active.last.title})")
        elsif respond_to? :training_schedule
          if (inherit_from = training_schedule&.presences&.find_by(member: team_member.member)).present?
            # Inherit fields from training schedule
            %w[is_present on_time signed_off remark].each do |field|
              presence.write_attribute(field, inherit_from.send(field))
            end
            presence.save!
          end
        end
      end
    end

    if is_a?(TrainingSchedule) || started_at > Time.zone.now
      # Update presences: add new team members
      team.team_members.player.active.asc.each do |team_member|
        next if presences.where(member: team_member.member).present?

        presences.create(member: team_member.member, team: team)
      end

      # Remove inactive team members
      member_ids = team.team_members.archived.pluck(:member_id)
      presences.where(member: member_ids).delete_all
    end

    presences.team(team)
  end

  def present_size_for_label(team)
    return presences.team(team).present.size if presences.team(team).any?

    -1
  end
end
