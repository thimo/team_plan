# frozen_string_literal: true

class KeepersController < ApplicationController
  before_action :add_breadcrumbs

  def index
    @season = Season.active_season_for_today
    return if @season.nil?

    age_groups = policy_scope(@season.age_groups).active.asc
    @keepers_male = age_groups_array(age_groups.male)
    @keepers_female = age_groups_array(age_groups.female)
  end

  private

    def add_breadcrumbs
      add_breadcrumb "Keepers", keepers_path
    end

    def age_groups_array(age_groups)
      age_groups.map { |ag| age_group_hash(ag) }
    end

    def age_group_hash(age_group)
      {
        age_group: age_group,
        keepers: age_group.team_members.goalkeeper.active
                          .group_by(&:member)
                          .sort_by { |member, _tms| [member.last_name, member.first_name] }
      }
    end
end
