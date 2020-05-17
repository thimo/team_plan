class AgeGroupsController < ApplicationController
  include SortHelper

  before_action :create_age_group, only: [:new, :create]
  before_action :set_age_group, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show
    @teams = human_sort(policy_scope(@age_group.teams), :name)
    set_evaluations
    set_members
    set_todos
    @injureds = policy_scope(Member).by_age_group_as_active_player(@age_group).player.injured.asc
    set_matches
    set_play_bans
    set_teams_with_inactive_players
  end

  def new
  end

  def create
    if params[:refresh_only].blank? && @age_group.save
      redirect_to @age_group, notice: "Leeftijdsgroep is toegevoegd."
    else
      render :new
    end
  end

  def edit
  end

  def update
    old_status = @age_group.status

    @age_group.attributes = permitted_attributes(@age_group)

    if params[:refresh_only].blank? && @age_group.save
      @age_group.transmit_status(@age_group.status, old_status)

      redirect_to @age_group, notice: "Leeftijdsgroep is aangepast."
    else
      render "edit"
    end
  end

  def destroy
    redirect_to @age_group.season, notice: "Leeftijdsgroep is verwijderd."
    @age_group.destroy
  end

  private

  def create_age_group
    @season = Season.find(params[:season_id])

    @age_group = if action_name == "new"
      @season.age_groups.new
    else
      AgeGroup.new(permitted_attributes(AgeGroup.new))
    end
    @age_group.season = @season

    authorize @age_group
  end

  def set_age_group
    @age_group = AgeGroup.find(params[:id])
    authorize @age_group
  end

  def add_breadcrumbs
    add_breadcrumb @age_group.season.name, @age_group.season
    if @age_group.new_record?
      add_breadcrumb "Nieuw"
    else
      add_breadcrumb @age_group.name.to_s, @age_group
    end
  end

  def set_evaluations
    return unless policy(@age_group).show_evaluations?

    @open_team_evaluations = TeamEvaluation.open_at_team.by_age_group(@age_group).asc
    @finished_team_evaluations = TeamEvaluation.finished.desc_finished.by_age_group(@age_group)
  end

  def set_members
    return unless policy(@age_group).show_available_members?

    available_players = @age_group.active_players.order_registered_at - @age_group.assigned_active_players
    @available_players = Kaminari.paginate_array(available_players).page(params[:member_page]).per(10)

    available_non_players = @age_group.active_non_players - @age_group.assigned_active_non_players
    @available_non_players = Kaminari.paginate_array(available_non_players).page(params[:member_page]).per(10)
  end

  def set_todos
    todos = policy_scope(@age_group.todos).unfinished.asc.includes(:todoable)
    @todos_active = todos.active.to_a
    @todos_defered = todos.defered.to_a
    todos = policy_scope(Todo).where(todoable_type: Team.name, todoable_id: @age_group.teams.map(&:id))
      .unfinished.asc.includes(:todoable)
    @todos_active += todos.active
    @todos_defered += todos.defered
    todos = policy_scope(Todo).where(todoable_type: Member.name, todoable_id: policy_scope(Member)
                              .by_age_group(@age_group).map(&:id)).unfinished.asc.includes(:todoable)
    @todos_active += todos.active
    @todos_defered += todos.defered
  end

  def set_matches
    matches = @age_group.matches.distinct.includes([:competition])

    @not_played_matches = grouped(matches.not_played.in_period(Time.zone.today, 1.week.from_now.end_of_day))
    @played_matches = grouped(matches.played.in_period(1.week.ago.end_of_day, Time.zone.tomorrow))
  end

  def grouped(matches)
    matches.group_by { |match| match.started_at.to_date }.sort_by { |date, _matches| date }
  end

  def set_play_bans
    return unless policy(@age_group).show_play_bans?

    members = Member.by_age_group(@age_group)
    play_bans = PlayBan.by_member(members).order_started_on
    @play_bans = play_bans.active
    @play_bans_future = play_bans.start_in_future
  end

  def set_teams_with_inactive_players
    return unless @age_group.active?

    @teams_with_inactive_players = @teams.map { |team|
      team if policy(team).show_alert? && team.inactive_players?
    }.compact
  end
end
