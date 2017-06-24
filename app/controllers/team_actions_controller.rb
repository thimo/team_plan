class TeamActionsController < ApplicationController
  include SortHelper

  def new
    @age_group = policy_scope(AgeGroup).find(params[:age_group_id])
    @teams = human_sort(policy_scope(@age_group.teams), :name)
    authorize :team_action

    case params[:type]
    when 'email'
      @title = "Stuur e-mail aan teams"
      @button_label = "Versturen"
    when 'download_team_members'
      @title = "Download teams naar Excel"
      @button_label = "Downloaden"
    end
  end

  def create
    @age_group = policy_scope(AgeGroup).find(params[:age_group_id])
    authorize :team_action

    case params[:type]
    when 'email'
      @teams = policy_scope(Team).where(id: params[:team_ids])
      email_addresses = []
      @teams.each do |team|
        active_members = team.team_members.active_for_team(team)
        email_addresses << active_members.player.map(&:email) if include_players?
        email_addresses << active_members.staff.map(&:email)  if include_staff?
      end

      # Collect email addresses
      @redirect = "mailto:#{email_addresses.uniq.join(',')}"
    when 'download_team_members'
      @redirect = age_group_download_team_members_path(@age_group, format: "xlsx", team_ids: params[:team_ids], status: params[:status])
    end
  end

  private

    def include_staff?
      params[:email_selection] == 'all' || params[:email_selection] == 'staff'
    end

    def include_players?
      params[:email_selection] == 'all' || params[:email_selection] == 'player'
    end
end
