class TeamEvaluationBulkUpdatesController < ApplicationController
  include SortHelper

  before_action :set_age_group, only: [:new, :create]
  before_action :add_breadcrumbs

  def new
    @teams = human_sort(policy_scope(@age_group.teams.active), :name)
  end

  def create
    team_ids = params[:team_ids]
    count = 0
    mail_count = 0

    team_ids.each do |id|
      team = Team.find(id)
      team_evaluation = team.team_evaluations.new
      authorize team_evaluation

      team_evaluation.team.team_members.active.player.asc.each do |player|
        team_evaluation.player_evaluations.build(team_member: player)
      end

      team_evaluation.save
      count += 1

      mail_count += team_evaluation.send_invites(current_user)
    end

    if count == 0
      flash[:alert] = "Er zijn geen teamevaluaties aangemaakt (#{mail_count} e-mails verstuurd)"
    elsif count == 1
      flash[:success] = "Er is één teamevaluatie aangemaakt (#{mail_count} e-mails verstuurd)"
    else
      flash[:success] = "Er zijn #{count} teamevaluaties aangemaakt (#{mail_count} e-mails verstuurd)"
    end

    redirect_to @age_group
  end

  private

    def set_age_group
      @age_group = AgeGroup.find(params[:age_group_id])
      authorize Team.new(age_group: @age_group)
    end

    def add_breadcrumbs
      add_breadcrumb "#{@age_group.season.name}", @age_group.season
      add_breadcrumb @age_group.name, @age_group
      add_breadcrumb 'Nieuw'
    end
  end
