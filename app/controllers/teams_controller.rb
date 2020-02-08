# frozen_string_literal: true

class TeamsController < ApplicationController
  include TeamsHelper

  before_action :create_team, only: [:new, :create]
  before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show
    set_active_tab

    @previous_season = @team.age_group.season.previous

    case @active_tab
    when "team"
      @players = TeamMember.players_by_year(policy_scope(@team.team_members)
                           .includes([:field_positions, :field_positions_teammembers]).not_ended)
      @staff = TeamMember.staff_by_member(policy_scope(@team.team_members).not_ended)
      @old_members = policy_scope(@team.team_members).ended.includes(:member).group_by(&:member)

      todos = policy_scope(@team.todos).unfinished.includes(:todoable)
      @todos_active = todos.active.to_a
      @todos_defered = todos.defered.to_a
      todos = policy_scope(Todo).where(todoable_type: Member.name, todoable_id: policy_scope(Member).by_team(@team)
                                .map(&:id)).unfinished.asc
      @todos_active += todos.active
      @todos_defered += todos.defered

      if policy(@team).show_play_bans?
        play_bans = PlayBan.by_member(@team.members).order_started_on
        @play_bans = play_bans.active
        @play_bans_future = play_bans.start_in_future
      end

    when "competitions"
      @competitions_regular = @team.competitions.knvb.desc.active.regular
      @competitions_other   = @team.competitions.knvb.desc.active.other

      @custom_competition_matches = @team.matches.for_competition(Competition.custom).desc.group_by(&:competition)
                                         .sort_by { |competition, _matches| competition.id }

    when "dossier"
      @notes = Note.for_user(policy_scope(@team.notes), @team, current_user).desc
      @team_evaluations = policy_scope(@team.team_evaluations).desc

    when "statistics"
      team_presence_graphs

    when "schedule"
      @not_played_matches = @team.matches.not_played.from_today.includes(:competition).asc
      @played_matches = @team.matches.played.includes(:competition).desc

      @training_schedules = policy_scope(@team.training_schedules).active.includes(:soccer_field, :team_members).asc
      @trainings = @team.trainings.in_period(0.days.ago.beginning_of_day, 4.weeks.from_now.beginning_of_day)
                        .includes(:training_schedule, training_schedule: :soccer_field).asc

    when "calendar"
      date = params[:start_date].present? ? Time.zone.parse(params[:start_date]) : Time.zone.now
      @schedules = @team.schedules(from: date - 1.month, up_to: date + 1.month)
    end
  end

  def new; end

  def create
    if @team.save
      redirect_to @team, notice: "Team is toegevoegd."
    else
      render :new
    end
  end

  def edit; end

  def update
    old_status = @team.status

    if @team.update(permitted_attributes(@team))
      @team.transmit_status(@team.status, old_status)

      redirect_to @team, notice: "Team is aangepast."
    else
      render "edit"
    end
  end

  def destroy
    redirect_to @team.age_group, notice: "Team is verwijderd."
    @team.destroy
  end

  private

    def create_team
      @age_group = AgeGroup.find(params[:age_group_id])

      @team = if action_name == "new"
                @age_group.teams.new
              else
                Team.new(permitted_attributes(Team.new))
              end
      @team.age_group = @age_group

      authorize @team
    end

    def set_team
      @team = Team.find(params[:id])
      authorize @team
    end

    def add_breadcrumbs
      add_breadcrumb @team.age_group.season.name, @team.age_group.season
      add_breadcrumb @team.age_group.name, @team.age_group
      if @team.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @team.name_with_club, @team
      end
    end

    def set_active_tab
      @active_tab = params[:tab].presence || current_user.setting(:active_team_tab).presence || "team"
      @active_tab = "team" unless policy(@team).try("show_#{@active_tab}?")
      current_user.set_setting(:active_team_tab, @active_tab)
    end
end
