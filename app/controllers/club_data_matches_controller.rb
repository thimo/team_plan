class ClubDataMatchesController < ApplicationController
  include SchedulesHelper

  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :set_team, only: [:show]
  before_action :add_breadcrumbs, only: [:show]

  def show
    if policy(@match).show_presences? && @team.present?
      @presences = @match.find_or_create_presences(@team).asc
      @players = @presences.present
    end
  end

  def destroy
    redirect_to @match.team, notice: "Wedstrijd is verwijderd."
    @match.destroy
  end

  private

    def set_team
      @team = Team.find(params[:team]) if params[:team]
      @team ||= @match.teams.first if @match.teams.size == 1
    end

    def set_match
      @match = ClubDataMatch.find(params[:id])
      authorize @match
    end

    def match_params
      params.require(:match).permit(:opponent, :location, :body, :remark, :team_id, :started_at, :start_time)
    end

    def add_breadcrumbs
      [@team || @match.teams].flatten.each do |team|
        add_breadcrumb team.name, team
      end
      if @match.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb schedule_title(@match), @match
      end
    end
end
