class AgeGroupsController < ApplicationController
  include SortHelper

  before_action :create_age_group, only: [:new, :create]
  before_action :set_age_group, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show
    @open_team_evaluations = TeamEvaluation.open_at_team.by_age_group(@age_group).asc
    @finished_team_evaluations = TeamEvaluation.finished.desc_finished.by_age_group(@age_group)
    @teams = human_sort(policy_scope(@age_group.teams), :name)

    if policy(@age_group).show_available_members?
      available_members = @age_group.active_members - @age_group.assigned_active_members
      @available_members = Kaminari.paginate_array(available_members).page(params[:member_page]).per(10)
    end

    todos = policy_scope(@age_group.todos).unfinished.asc.includes(:todoable)
    @todos_active = todos.active.to_a
    @todos_defered = todos.defered.to_a
    todos = policy_scope(Todo).where(todoable_type: Team.name, todoable_id: @age_group.teams.map(&:id)).unfinished.asc.includes(:todoable)
    @todos_active += todos.active
    @todos_defered += todos.defered
    todos = policy_scope(Todo).where(todoable_type: Member.name, todoable_id: policy_scope(Member).by_age_group(@age_group).map(&:id)).unfinished.asc.includes(:todoable)
    @todos_active += todos.active
    @todos_defered += todos.defered

    @injureds = policy_scope(Member).by_age_group(@age_group).injured.asc
    @schedule_simple = true
    matches = @age_group.matches.not_played.in_period(0.days.ago.beginning_of_day, 1.week.from_now.end_of_day).distinct
    @not_played_matches = matches.group_by{ |match| match.started_at.to_date }.sort_by{|date, matches| date}
    matches = @age_group.matches.played.in_period(1.week.ago.end_of_day, 0.days.from_now.end_of_day).distinct
    @played_matches = matches.group_by{ |match| match.started_at.to_date }.sort_by{|date, matches| date}
  end

  def new; end

  def create
    if @age_group.save
      redirect_to @age_group, notice: 'Leeftijdsgroep is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    old_status = @age_group.status

    if @age_group.update_attributes(permitted_attributes(@age_group))
      @age_group.transmit_status(@age_group.status, old_status)

      redirect_to @age_group, notice: 'Leeftijdsgroep is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @age_group.season, notice: 'Leeftijdsgroep is verwijderd.'
    @age_group.destroy
  end

  private

    def create_age_group
      @season = Season.find(params[:season_id])

      @age_group = if action_name == 'new'
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
      add_breadcrumb "#{@age_group.season.name}", @age_group.season
      if @age_group.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @age_group.name.to_s, @age_group
      end
    end

    # def age_group_params
    #   params.require(:age_group).permit(:name, :year_of_birth_from, :year_of_birth_to, :gender)
    #   # :status if policy change status
    # end
end
