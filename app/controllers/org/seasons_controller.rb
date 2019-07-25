# frozen_string_literal: true

module Org
  class SeasonsController < Org::BaseController
    include SortHelper

    before_action :set_season
    before_action :add_breadcrumbs

    def show
      @age_groups_male = age_groups_for(@season, :male)
      @age_groups_female = age_groups_for(@season, :female)

      key = "org_seasons_#{@season.id}_expand".to_sym
      params[:expand] ||= current_user.setting(key)
      return if params[:expand].blank?

      current_user.set_setting(key, params[:expand])

      age_group = policy_scope(AgeGroup.find_by(id: params[:expand]))
      @teams = teams_for(age_group)
    end

    private

      def set_season
        @season = policy_scope(Season).find(params[:id])
        authorize @season
      end

      def add_breadcrumbs; end

      def age_groups_for(season, gender)
        policy_scope(season.age_groups).send(gender).asc.map do |age_group|
          {
            age_group: age_group,
            count: age_group.teams.sum { |team| staff_for(team).size }
          }
        end
      end

      def teams_for(age_group)
        return [] if age_group.blank?

        human_sort(policy_scope(age_group.teams), :name).map do |team|
          {
            team: team,
            title: team.name_with_club,
            staff: sorted_staff_for(team).map do |member, team_members|
              {
                member: member,
                name: member.name,
                roles: team_members.map(&:role_i18n)
              }
            end
          }
        end
      end

      def staff_for(team)
        team.team_members
            .staff
            .active_or_archived
      end

      def sorted_staff_for(team)
        staff_for(team)
          .group_by(&:member)
          .sort_by { |member, _tm| member.last_name }
      end
  end
end
