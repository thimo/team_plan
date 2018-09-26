# frozen_string_literal: true

class GroupMembersController < ApplicationController
  before_action :create_group_member, only: [:new, :create]
  before_action :set_group_member, only: [:destroy]
  before_action :add_breadcrumbs, only: [:new]

  def new; end

  def create
    # TODO: Redirect to group or memberable
    if @group_member.save
      redirect_to TODO, notice: "TODO is toegevoegd"
    else
      render :new
    end
  end

  def destroy
    # TODO: Redirect to group or memberable
    redirect_to TODO, notice: "TODO is verwijderd."
    @group.destroy
  end

  private

    def create_group_member
      # return if params[:group_id].blank?

      @group = Group.find(params[:group_id])

      @group_member = if action_name == "new"
                        @group.group_members.new
                      else
                        GroupMember.new(permitted_attributes(GroupMember.new(group: @group)))
                      end
      @group_member.group ||= @group

      authorize @group_member
    end

    def set_group_member
      @group_member = GroupMember.find(params[:id])
      authorize @group_member
    end

    def add_breadcrumbs
      # add_breadcrumb @group_member.team.age_group.season.name, @group_member.team.age_group.season
      # add_breadcrumb @group_member.team.age_group.name, @group_member.team.age_group
      # add_breadcrumb @group_member.team.name, @group_member.team
      # if @group_member.new_record?
      #   add_breadcrumb "Nieuw"
      # else
      #   add_breadcrumb @group_member.member.name, @group_member
      # end
    end
end
