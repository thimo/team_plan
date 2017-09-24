class TeamMemberBulkUpdatesController < ApplicationController
  before_action :set_team, only: [:new, :create]
  before_action :add_breadcrumbs

  def new
    @members = Member.asc.all
  end

  def create
    count = 0

    %w[player coach trainer team_parent].each do |type|
      ids = params[type.pluralize]
      ids.each do |id|
        member = Member.find(id)
        unless member.nil?
          @team_member = @team.team_members.new(member: member, role: TeamMember.roles["#{type}"])
          @team_member.status = @team.status
          if @team_member.save
            count += 1
          end
        end
      end unless ids.nil?
    end

    if count == 0
      flash[:alert] = "Er zijn geen teamgenoten toegevoegd aan #{@team.name}"
    elsif count == 1
      flash[:success] = "Er is één teamgenoot toegevoegd aan #{@team.name}"
    else
      flash[:success] = "Er zijn #{count} teamgenoten toegevoegd aan #{@team.name}"
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
      add_breadcrumb "#{@team.age_group.season.name}", @team.age_group.season
      add_breadcrumb @team.age_group.name, @team.age_group
      add_breadcrumb @team.name, @team
      add_breadcrumb 'Nieuw'
    end
end
