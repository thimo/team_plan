# frozen_string_literal: true

class GroupMembersController < ApplicationController
  before_action :load_memberable, only: [:new, :create]
  before_action :create_group_member, only: [:new, :create]
  before_action :set_group_member, only: [:destroy]
  before_action :add_breadcrumbs, only: [:new]

  def new; end

  def create
    if @group_member.save
      redirect_to @group_member.memberable, notice: "#{@group_member.member.name} is toegevoegd"
    else
      render :new
    end
  end

  def destroy
    # TODO: Redirect to group or memberable
    redirect_to @group_member.memberable, notice: "#{@group_member.member.name} is verwijderd."
    @group_member.destroy
  end

  private

    def create_group_member
      @group_member = if action_name == "new"
                        GroupMember.new
                      else
                        GroupMember.new(group_member_params)
                      end
      @group_member.memberable = @memberable
      @group_member.group ||= Group.find(params[:group_id])
      authorize @group_member
    end

    def set_group_member
      @group_member = GroupMember.find(params[:id])
      authorize @group_member
    end

    def load_memberable
      resource, id = request.path.split("/")[1, 2]
      @memberable = resource.singularize.classify.constantize.find(id)
    end

    def add_breadcrumbs
      add_breadcrumb @group_member.memberable.name, @group_member.memberable
      # add_breadcrumb @group_member.team.age_group.name, @group_member.team.age_group
      # add_breadcrumb @group_member.team.name_with_club, @group_member.team
      if @group_member.new_record?
        add_breadcrumb "Nieuw"
      end
    end

    def group_member_params
      params.require(:group_member).permit(:group_id, :member_id, :memberable_type, :memberable_id)
    end
end
