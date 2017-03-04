class MemberAllocationFiltersController < ApplicationController
  after_action :skip_authorization

  def create
    session[:filter_field_position] = filter_params[:field_position].reject(&:empty?)
    redirect_to :back, notice: "Filter is toegepast."
  end

  def destroy
    session[:filter_field_position] = nil
    redirect_to :back, notice: "Filter is verwijderd."
  end

  private

    def filter_params
      params.require(:member_allocation_filters).permit(field_position: [])
    end
end
