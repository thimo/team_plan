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
        email_addresses << team.team_members.player.map(&:email) if params[:email_selection] == 'all' || params[:email_selection] == 'player'
        email_addresses << team.team_members.staff.map(&:email) if params[:email_selection] == 'all' || params[:email_selection] == 'staff'
      end

      # Collect email addresses
      @redirect = "mailto:#{email_addresses.uniq.join(',')}"
    when 'download_team_members'
      @redirect = age_group_download_team_members_path(@age_group, format: "xlsx", team_ids: params[:team_ids])
    end

  end
end
