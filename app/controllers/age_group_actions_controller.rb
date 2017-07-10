class AgeGroupActionsController < ApplicationController
  include SortHelper

  def new
    @season = policy_scope(Season).find(params[:season_id])
    @age_groups_male = policy_scope(@season.age_groups).male.asc
    @age_groups_female = policy_scope(@season.age_groups).female.asc
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
    @season = policy_scope(Season).find(params[:season_id])
    authorize :team_action

    case params[:type]
    when 'email'
      current_user.settings.update_attribute(:email_separator, params[:email_separator])

      @age_groups = policy_scope(AgeGroup).where(id: params[:age_group_ids])
      email_addresses = []
      @age_groups.each do |age_group|
        age_group.teams.each do |team|
          active_members = team.team_members.active_for_team(team)
          email_addresses << active_members.player.map(&:email) if include_players?
          email_addresses << active_members.staff.map(&:email)  if include_staff?
        end
      end

      # Collect email addresses
      @redirect = "mailto:#{email_addresses.uniq.join(current_user.settings.email_separator)}"
    when 'download_team_members'
      # TODO
      # @redirect = age_group_download_team_members_path(@age_group, format: "xlsx", team_ids: params[:team_ids], status: params[:status])
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
