class MatchesController < ApplicationController
  include SchedulesHelper

  before_action :set_team, only: [:new, :create]
  before_action :create_match, only: [:new, :create]
  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show
    @presences = policy_scope(@match.find_or_create_presences.asc)
    @players = @presences.present
  end

  def new
  end

  def create
    if @match.save
      redirect_to @match, notice: "Wedstrijd is toegevoegd."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @match.update_attributes(match_params.merge(user_modified: true))
      redirect_to @match, notice: "Wedstrijd is aangepast."
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @match.team, notice: "Wedstrijd is verwijderd."
    @match.destroy
  end

  private
    def set_team
      @team = @match&.team || Team.find(params[:team_id])
    end

    def create_match
      @match = if action_name == 'new'
                  @team.matches.new
                else
                  Match.new(match_params.merge(user_modified: true))
                end
      @match.team = @team

      authorize @match
    end

    def set_match
      @match = Match.find(params[:id])
      authorize @match
    end

    def match_params
      params.require(:match).permit(:opponent, :location, :body, :remark, :team_id, :started_at, :start_time)
    end

    def add_breadcrumbs
      add_breadcrumb "#{@match.team.name}", @match.team
      if @match.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb schedule_title(@match), @match
      end
    end
end
