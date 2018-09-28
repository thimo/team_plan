# frozen_string_literal: true

module Admin
  class SoccerFieldsController < Admin::BaseController
    before_action :create_soccer_field, only: [:new, :create]
    before_action :set_soccer_field, only: [:edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      @soccer_fields = policy_scope(SoccerField).asc
      authorize @soccer_fields
    end

    def new; end

    def create
      if @soccer_field.save
        redirect_to admin_soccer_fields_path, notice: "Veld is toegevoegd."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @soccer_field.update(soccer_field_params)
        redirect_to admin_soccer_fields_path, notice: "Veld is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_soccer_fields_path, notice: "Veld is verwijderd."
      @soccer_field.destroy
    end

    private

      def create_soccer_field
        @soccer_field = if action_name == "new"
                          SoccerField.new
                        else
                          SoccerField.new(soccer_field_params)
                        end
        authorize @soccer_field
      end

      def set_soccer_field
        @soccer_field = SoccerField.find(params[:id])
        authorize @soccer_field
      end

      def soccer_field_params
        params.require(:soccer_field).permit(:name, :training, :match)
      end

      def add_breadcrumbs
        add_breadcrumb "Velden", admin_soccer_fields_path
        return if @soccer_field.nil?

        if @soccer_field.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @soccer_field.name, [:edit, :admin, @soccer_field]
        end
      end
  end
end
