class MemberAllocationsController < ApplicationController
  include SortHelper

  def index
    @age_group = AgeGroup.find(params[:age_group_id])
    @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
    @filter_field_position = session[:filter_field_position]

    # All active players
    members = policy_scope(Member).active_players.asc
    # Filter on year of birth
    members = members.from_year(@age_group.year_of_birth_from) unless @age_group.year_of_birth_from.nil?
    members = members.to_year(@age_group.year_of_birth_to) unless @age_group.year_of_birth_to.nil?
    # Filter on gender
    unless @age_group.gender.nil?
      case @age_group.gender.upcase
      when "M"
        members = members.male
      when "V"
        members = members.female
      end
    end

    @available_members = []
    # Filter out members who have already been assigned to a team
    members.each do |member|
      if session[:filter_field_position].nil? ||
          member.active_team_member.present? && session[:filter_field_position].include?(member.active_team_member.field_position)
        @available_members << member if @age_group.is_not_member(member)
      end
    end

    add_breadcrumb @age_group.season.name.to_s, @age_group.season
    add_breadcrumb @age_group.name.to_s, @age_group
    add_breadcrumb 'Indeling'
  end

  def create; end

  def update; end

  def destroy
    @team_member = TeamMember.find(params[:id])
    authorize @team_member
    @team_member.destroy

    redirect_to :back, notice: "Teamlid is verwijderd uit het team."
  end

  private
end
