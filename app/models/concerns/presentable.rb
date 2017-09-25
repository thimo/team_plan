module Presentable
  extend ActiveSupport::Concern

  included do
    has_many :presences, as: :presentable, dependent: :destroy
  end

  def find_or_create_presences
    if presences.empty?
      # Add presences for all local teams (can be two local teams per match)
      teams.each do |team|
        team.team_members.player.active.asc.each do |team_member|
          presence = presences.create({ member: team_member.member, team: team })

          if team_member.member.injured?
              presence.update(present: false, remark: "Blessure (#{team_member.member.injuries.active.last.title})")
          else
            if respond_to? :training_schedule
              unless (inherit_from = training_schedule.presences&.find_by(member: team_member.member)).blank?
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
    end

    if self.is_a? TrainingSchedule || started_at > Time.zone.now
      # Update presences: add new team members
      # TODO remove inactive team members
      teams.each do |team|
        team.team_members.player.active.asc.each do |team_member|
          if presences.where(member: team_member.member).empty?
            presences.create({ member: team_member.member, team: team })
          end
        end
      end
    end

    presences
  end

  private

  module ClassMethods
  end

end
