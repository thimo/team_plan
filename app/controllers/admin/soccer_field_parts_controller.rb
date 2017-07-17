class Admin::SoccerFieldPartPartsController < ApplicationController
  before_action :create_soccer_field_part, only: [:new, :create]
  before_action :set_soccer_field_part, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def index
    # TODO: add paging
    @soccer_field_parts = policy_scope(SoccerFieldPart).asc
  end

  def new; end

  def create
    if @soccer_field_part.save
      redirect_to admin_soccer_field_parts_path, notice: 'Veld is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @soccer_field_part.update_attributes(soccer_field_part_params)
      redirect_to admin_soccer_field_parts_path, notice: 'Veld is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to admin_soccer_field_parts_path, notice: 'Veld is verwijderd.'
    @soccer_field_part.destroy
  end

  private

    def create_soccer_field_part
      @soccer_field_part = if action_name == 'new'
                          SoccerFieldPart.new
                        else
                          SoccerFieldPart.new(soccer_field_part_params)
                        end
      authorize @soccer_field_part
    end

    def set_soccer_field_part
      @soccer_field_part = SoccerFieldPart.find(params[:id])
      authorize @soccer_field_part
    end

    def soccer_field_part_params
      params.require(:soccer_field_part).permit(:name, :soccer_field)
    end

    def add_breadcrumbs
      add_breadcrumb 'Velden', admin_soccer_field_path
      add_breadcrumb soccer_field_parts.soccer_field.name, soccer_field_parts.soccer_field
      unless @soccer_field_part.nil?
        if @soccer_field_part.new_record?
          add_breadcrumb 'Nieuw'
        else
          add_breadcrumb @soccer_field_part.name, [:edit, :admin, @soccer_field_part]
        end
      end
    end
end
