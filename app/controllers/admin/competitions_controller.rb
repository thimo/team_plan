# frozen_string_literal: true

module Admin
  class CompetitionsController < Admin::BaseController
    before_action :create_competition, only: [:new, :create]
    before_action :set_competition, only: [:edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      @competitions = policy_scope(Competition).custom.asc
      authorize @competitions
    end

    def new; end

    def create
      if @competition.save
        redirect_to admin_competitions_path, notice: "Wedstrijdsoort is toegevoegd."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @competition.update(competition_params)
        redirect_to admin_competitions_path, notice: "Wedstrijdsoort is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_competitions_path, notice: "Wedstrijdsoort is verwijderd."
      @competition.destroy
    end

    private

      def create_competition
        @competition = if action_name == "new"
                         Competition.new
                       else
                         Competition.new(competition_params.merge(poulecode: Competition.new_custom_poulecode))
                       end
        authorize @competition
      end

      def set_competition
        @competition = Competition.find(params[:id])
        authorize @competition
      end

      def competition_params
        params.require(:competition).permit(:competitienaam, :competitiesoort)
      end

      def add_breadcrumbs
        add_breadcrumb "Wedstrijdsoorten", admin_competitions_path
        return if @competition.nil?

        if @competition.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @competition.competitienaam, [:edit, :admin, @competition]
        end
      end
  end
end
