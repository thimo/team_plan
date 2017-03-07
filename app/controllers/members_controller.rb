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

      team = @member.active_team # default
      team = @member.active_team_member.team unless @member.active_team_member.nil?

      if team.present?
        add_breadcrumb "#{team.age_group.season.name}", team.age_group.season
        add_breadcrumb "#{team.age_group.name}", team.age_group
        add_breadcrumb "#{team.name}", team
      end
      add_breadcrumb "#{@member.name}", @member
    end

end
