class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update]

  def show
    @team_members = @member.team_members.order(created_at: :desc)

    @commentable = @member
    @comments = @commentable.comments.includes(:user)
    @comment = Comment.new
  end

  def edit
  end

  private
  def set_member
    @member = Member.find(params[:id])
    authorize @member

    # TODO add breadcrumb for current active team
    # add_breadcrumb "#{@member.team.year_group.season.name}", @member.team.year_group.season
    # add_breadcrumb "#{@member.team.year_group.name}", @member.team.year_group
    # add_breadcrumb "#{@member.team.name}", @member.team
    add_breadcrumb "#{@member.name}", @member
  end

end
