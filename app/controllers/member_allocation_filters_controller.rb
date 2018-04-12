# frozen_string_literal: true

class MemberAllocationFiltersController < ApplicationController
  after_action :skip_authorization

  def create
    session[:filter_field_position] = filter_params[:field_position]
    session[:filter_team] = filter_params[:team]
    redirect_to :back, notice: "Filter is toegepast."
  end

  def destroy
    session[:filter_field_position] = nil
    session[:filter_team] = nil
    redirect_to :back, notice: "Filter is verwijderd."
  end

  private

    def filter_params
      params.require(:member_allocation_filters).permit(:team, :field_position)
    end
end
