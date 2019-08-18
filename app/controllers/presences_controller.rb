# frozen_string_literal: true

class PresencesController < ApplicationController
  before_action :load_presentable, only: [:new, :create]
  before_action :create_presence, only: [:new, :create]
  before_action :set_parent, only: [:index]
  before_action :set_presence, only: [:update]
  before_action :add_breadcrumbs, only: [:new]

  def index
    @team = Team.find(params[:team]) if params[:team]
    @presences = policy_scope(@parent.find_or_create_presences(@team)).asc
  end

  def new; end

  def create
    if @presence.save
      redirect_to @presence.presentable, notice: "#{@presence.member.name} is toegevoegd"
    else
      render :new
    end
  end

  def update
    @presence.update(permitted_attributes(@presence))
    @present_count = @presence.presentable.presences.present.size
  end

  private

    def create_presence
      @presence = if action_name == "new"
                    Presence.new
                  else
                    Presence.new(permitted_attributes(Presence.new))
                  end
      @presence.presentable = @presentable
      # @presence.group ||= Group.find(params[:group_id])
      authorize @presence
    end

    def set_parent
      @parent = if params[:training_id]
                  Training.find(params[:training_id])
                elsif params[:match_id]
                  Match.find(params[:match_id])
                end
    end

    def set_presence
      @presence = Presence.find(params[:id])
      authorize @presence
    end

    # def presence_params
    #   # Add member if new record
    #   params.require(:presence).permit(:is_present, :on_time, :signed_off, :remark)
    # end

    def load_presentable
      resource, id = request.path.split("/")[1, 2]
      @presentable = resource.singularize.classify.constantize.find(id)
    end

    def add_breadcrumbs
      add_breadcrumb @presence.presentable.title, @presence.presentable
      add_breadcrumb "Nieuw" if @presence.new_record?
    end
end
