# frozen_string_literal: true

class TeamMemberBulkUpdatesController < ApplicationController
  before_action :set_team, only: [:new, :create]
  before_action :add_breadcrumbs

  def new
    @members = Member.asc.all
  end

  def create
    count = 0

    %w[player coach trainer].each do |type|
      ids = params[type.pluralize]
      next if ids.nil?

      ids.each do |id|
        member = Member.find_by(id: id)
        next if member.nil?

        @team_member = @team.team_members.new(member: member, role: TeamMember.roles[type])
        @team_member.status = @team.status

        count += 1 if @team_member.save
      end
    end

    if count.zero?
      flash_message(:alert, "Er zijn geen teamgenoten toegevoegd aan #{@team.name}")
    elsif count == 1
      flash_message(:success, "Er is één teamgenoot toegevoegd aan #{@team.name}")
    else
      flash_message(:success, "Er zijn #{count} teamgenoten toegevoegd aan #{@team.name}")
    end

    case params[:from]
    when "member_allocations"
      redirect_to age_group_member_allocations_path(@team.age_group)
    else
      redirect_to @team
    end
  end

  private

    def set_team
      @team = Team.find(params[:team_id])
      authorize TeamMember.new(team: @team)
    end

    def add_breadcrumbs
      add_breadcrumb @team.age_group.season.name, @team.age_group.season
      add_breadcrumb @team.age_group.name, @team.age_group
      add_breadcrumb @team.name_with_club, @team
      add_breadcrumb "Nieuw"
    end
end
