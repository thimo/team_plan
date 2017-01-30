class TeamMembersController < ApplicationController
  before_action :set_team_member, only: [:edit, :update, :destroy]

  def new
  end

  def edit
  end

  def destroy
  end

  private
    def set_team_member
      @team_member = TeamMember.find(params[:id])
      authorize @team_member
    end
end
