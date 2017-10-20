module Presentable
  extend ActiveSupport::Concern

  included do
    has_many :presences, as: :presentable, dependent: :destroy
  end

  def find_or_create_presences(team = nil)
    team ||= self.team
    
    if presences.team(team).empty?
      # Add presences for all local teams (can be two local teams per match)
      team.team_members.player.active.asc.each do |team_member|
        presence = presences.create({ member: team_member.member, team: team })

        if team_member.member.injured?
            presence.update(present: false, remark: "Blessure (#{team_member.member.injuries.active.last.title})")
        else
          if respond_to? :training_schedule
            unless (inherit_from = training_schedule&.presences&.find_by(member: team_member.member)).blank?
              # Inherit fields from training schedule
              %w[present on_time signed_off remark].each do |field|
                presence.write_attribute(field, inherit_from.send(field))
              end
              presence.save!
            end
          end
        end
      end
    end

    if self.is_a?(TrainingSchedule) || started_at > Time.zone.now
      # Update presences: add new team members
      # TODO remove inactive team members
      team.team_members.player.active.asc.each do |team_member|
        if presences.where(member: team_member.member).empty?
          presences.create({ member: team_member.member, team: team })
        end
      end
    end

    presences.team(team)
  end

  def present_size_for_label(team)
    if presences.team(team).any?
      presences.team(team).present.size
    else
      if is_a?(Training) && training_schedule&.presences.any?
        training_schedule&.presences.present.size
      else
        team.team_members.player.active.size
      end
    end
  end

  private

    module ClassMethods
    end

end
