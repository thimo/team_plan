module Admin
  class TeamEvaluationConfigsController < Admin::BaseController
    before_action :create_resource, only: [:new, :create]
    before_action :set_resource, only: [:edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      @team_evaluation_configs = policy_scope(TeamEvaluationConfig).asc
      authorize @team_evaluation_configs
    end

    def new; end

    def create
      if @team_evaluation_config.save
        redirect_to admin_team_evaluation_configs_path, notice: "Teamevaluatie is toegevoegd."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @team_evaluation_config.update(team_evaluation_config_params)
        redirect_to admin_team_evaluation_configs_path, notice: "Teamevaluatie is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_team_evaluation_configs_path, notice: "Teamevaluatie is verwijderd."
      @team_evaluation_config.destroy
    end

    private

      def create_resource
        @team_evaluation_config = TeamEvaluationConfig.new(config: TeamEvaluationConfig::DEFAULT_CONFIG)
        @team_evaluation_config.update(permitted_attributes(@team_evaluation_config)) if action_name == "create"
        authorize @team_evaluation_config
      end

      def set_resource
        @team_evaluation_config = TeamEvaluationConfig.find(params[:id])
        authorize @team_evaluation_config
      end

      def add_breadcrumbs
        add_breadcrumb "Teamevaluaties", admin_team_evaluation_configs_path
        return if @team_evaluation_config.nil?

        if @team_evaluation_config.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @team_evaluation_config.name, [:edit, :admin, @team_evaluation_config]
        end
      end
  end
end
