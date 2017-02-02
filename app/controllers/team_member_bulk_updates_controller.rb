class TeamMemberBulkUpdatesController < ApplicationController
  before_action :set_team, only: [:new, :create]
  before_action :breadcumbs

  def new
    @members = Member.asc.all
  end

  def create
    players = params[:players]
    coaches = params[:coaches]
    trainers = params[:trainers]
    team_parents = params[:team_parents]

    count = 0

    players.each do |id|
      member = Member.find(id)
      unless member.nil?
        @team.team_members.create!(member: member, role: TeamMember.roles[:role_player])
        count += 1
      end
    end unless players.nil?

    coaches.each do |id|
      member = Member.find(id)
      unless member.nil?
        @team.team_members.create!(member: member, role: TeamMember.roles[:role_coach])
        count += 1
      end
    end unless coaches.nil?

    trainers.each do |id|
      member = Member.find(id)
      unless member.nil?
        @team.team_members.create!(member: member, role: TeamMember.roles[:role_trainer])
        count += 1
      end
    end unless trainers.nil?

    team_parents.each do |id|
      member = Member.find(id)
      unless member.nil?
        @team.team_members.create!(member: member, role: TeamMember.roles[:role_team_parent])
        count += 1
      end
    end unless team_parents.nil?

    if count == 0
      flash[:alert] = "Er zijn geen teamleden toegevoegd"
    elsif count == 1
      flash[:success] = "Er is 1 teamlid toegevoegd"
    else
      flash[:success] = "Er zijn #{count} teamleden toegevoegd"
    end

    redirect_to @team
  end

  private

    def set_team
      @team = Team.find(params[:team_id])
      authorize TeamMember
    end


    def breadcumbs
      add_breadcrumb "Seizoen #{@team.year_group.season.name}", @team.year_group.season
      add_breadcrumb @team.year_group.name, @team.year_group
      add_breadcrumb @team.name, @team
      add_breadcrumb 'Nieuw'
    end
end
