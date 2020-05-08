module Admin
  class MatchesController < Admin::BaseController
    before_action :create_resource, only: [:new, :create]
    before_action :set_resource, only: [:show, :edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      matches = policy_scope(Match).for_competition(Competition.custom)
      @matches_planned = matches.from_now.asc
      @matches_played = matches.in_past.desc
      authorize matches
    end

    def show
    end

    def new
    end

    def create
      if @match.save
        redirect_to admin_matches_path, notice: "Wedstrijd is toegevoegd."
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @match.update(match_params)
        redirect_to admin_matches_path, notice: "Wedstrijd is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_matches_path, notice: "Wedstrijd is verwijderd."
      @match.destroy
    end

    private

    def create_resource
      @match = if action_name == "new"
        Match.new
      else
        Match.new(match_params)
      end
      authorize @match
    end

    def set_resource
      @match = Match.find(params[:id])
      authorize @match
    end

    def match_params
      params.require(:match).permit(:name, member_ids: [], role_ids: [])
    end

    def add_breadcrumbs
      add_breadcrumb "Oefenwedstrijden", admin_matches_path
      return if @match.nil?

      if @match.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @match.name, [:edit, :admin, @match]
      end
    end
  end
end
