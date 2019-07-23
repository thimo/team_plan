# frozen_string_literal: true

class TeamActionsController < ApplicationController
  include SortHelper
  before_action :set_base, only: [:new, :create]

  def new
    case params[:type]
    when "email"
      @title = "Stuur e-mail aan teams"
      @button_label = "Versturen"
    when "download_team_members"
      @title = "Download teams naar Excel"
      @button_label = "Downloaden"
    when "publish"
      @title = "Teams publiceren naar een website"
      @button_label = "Publiceren"
    end
  end

  def create
    case params[:type]
    when "email"
      current_user.set_setting(:email_separator, params[:email_separator])

      # @teams = policy_scope(Team).where(id: params[:team_ids])
      email_addresses = []
      @teams.each do |team|
        active_members = team.team_members.active_for_team(team)
        email_addresses += active_members.player.map(&:email) if include_players?
        email_addresses += active_members.staff.map(&:email)  if include_staff?
      end

      # Collect email addresses
      emails = email_addresses.uniq.join(current_user.setting(:email_separator))
      @redirect = case params[:to_field]
                  when "cc"
                    "mailto:?cc=#{emails}"
                  when "bcc"
                    "mailto:?bcc=#{emails}"
                  else
                    "mailto:#{emails}"
                  end
    when "download_team_members"
      current_user.set_setting(:export_columns, params[:columns])

      @redirect = if @age_group.present?
                    age_group_download_team_members_path(@age_group, format: "xlsx", team_ids: params[:team_ids],
                                                                     status: params[:status])
                  elsif @season.present?
                    season_download_team_members_path(@season, format: "xlsx", age_group_ids: params[:age_group_ids],
                                                               status: params[:status])
                  end
    when "publish"
      @redirect = redirect_to season_publish_team_members_path(@season, age_group_ids: params[:age_group_ids],
                                                                        status: params[:status])
    end
  end

  private

    def set_base
      if params[:age_group_id].present?
        @age_group = policy_scope(AgeGroup).find(params[:age_group_id])
        authorize(@age_group, :team_actions?)
        @base_class = @age_group.class
        @teams = if params[:team_ids].present?
                   policy_scope(Team).where(id: params[:team_ids])
                 else
                   human_sort(policy_scope(@age_group.teams), :name)
                 end

      elsif params[:season_id].present?
        @season = policy_scope(Season).find(params[:season_id])
        authorize(@season, :team_actions?)
        @base_class = @season.class

        if params[:age_group_ids].present?
          # @age_groups = policy_scope(AgeGroup).where(id: params[:age_group_ids])
          @teams = policy_scope(Team).where(age_group: params[:age_group_ids])
        else
          @age_groups_male = policy_scope(@season.age_groups).male.asc
          @age_groups_female = policy_scope(@season.age_groups).female.asc
          @teams = policy_scope(Team).includes(:age_group).where(age_groups: { season: @season })
        end
      end
    end

    def include_staff?
      params[:email_selection] == "all" || params[:email_selection] == "staff"
    end

    def include_players?
      params[:email_selection] == "all" || params[:email_selection] == "player"
    end
end
