module Org
  class MembersController < Org::BaseController
    include SortHelper

    before_action :add_breadcrumbs

    def index
      authorize :org, :show_members?

      @season = Season.active_season_for_today
      @roles = roles_hash
      @groups = policy_scope(Group).asc

      params[:expand] ||= current_user.setting(:org_members_expand)
      return if params[:expand].blank?

      current_user.set_setting(:org_members_expand, params[:expand])

      if (group = @groups.find_by(id: params[:expand])).present?
        @members_title = group.name
        @group_members = group_hash(group)
      elsif (title = TeamMember.roles_i18n[params[:expand]]).present?
        @members_title = title
        @group_members = team_staff_hash(params[:expand])
      end
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Actieve leden"
      end

      def team_staff_members
        policy_scope(TeamMember.for_season(Season.last)).active.staff
      end

      def roles_hash
        roles = team_staff_members.pluck(:role)
        roles_hash = roles.uniq
                          .map { |role| { value: role, label: TeamMember.roles_i18n[role] } }
                          .sort_by { |role| role[:label] }
        roles_hash.each do |role|
          role[:count] = roles.count(role[:value])
        end
      end

      def group_hash(group)
        if group.memberable_via_type.blank?
          group.group_members.active
               .sort_by { |gm| gm.member.last_name }
               .map do |group_member|
                 {
                   member: group_member.member,
                   description: group_member.description
                 }
               end
        else
          group.group_members.active
               .group_by(&:member)
               .sort_by { |member, _gms| member.last_name }
               .map do |member, gms|
                 {
                   member: member,
                   description: human_sort(gms.map(&:memberable), :name).map(&:name).uniq.join(", ")
                 }
               end
        end
      end

      def team_staff_hash(role)
        team_staff_members.send(role)
                          .group_by(&:member)
                          .sort_by { |member, _tms| member.last_name }
                          .map do |member, tms|
                            {
                              member: member,
                              description: tms.map { |tm| tm.team.name_with_club }.join(", ")
                            }
                          end
      end
  end
end
