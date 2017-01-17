class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  private
    def set_member
      @member = Member.find(params[:id])
      authorize @member
    end
end
