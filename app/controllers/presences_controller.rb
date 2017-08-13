class PresencesController < ApplicationController
  # before_action :set_team, only: [:new, :create]
  # before_action :create_note, only: [:new, :create]
  before_action :set_presence, only: [:show, :edit, :update, :destroy]
  # before_action :add_breadcrumbs

  # def show; end

  # def new
  # end

  # def create
  #   if @presence.save
  #     redirect_to @presence, notice: "Notitie is toegevoegd."
  #   else
  #     render :new
  #   end
  # end

  # def edit
  # end

  def update
    if @presence.update_attributes(presence_params)
      @presence.set_presentable_user_modified
      @present_count = @presence.presentable.presences.present.size
      # redirect_to @presence, notice: "Notitie is aangepast."
    else
      # render 'edit'
    end
  end

  # def destroy
  #   redirect_to @presence.team, notice: "Notitie is verwijderd."
  #   @presence.destroy
  # end

  private
    # def set_team
    #   @team = if @presence.present? && @presence.team.present?
    #             @presence.team
    #           else
    #             Team.find(params[:team_id])
    #           end
    # end

    # def create_note
    #   @presence = if action_name == 'new'
    #             @team.notes.new
    #           else
    #             Presence.new(presence_params.merge(user: current_user))
    #           end
    #   @presence.team = @team
    #
    #   authorize @presence
    # end

    def set_presence
      @presence = Presence.find(params[:id])
      authorize @presence
    end

    def presence_params
      params.require(:presence).permit(:present, :on_time, :signed_off, :remark)
    end

    # def add_breadcrumbs
    #   add_breadcrumb "#{@presence.team.age_group.season.name}", @presence.team.age_group.season
    #   add_breadcrumb @presence.team.age_group.name, @presence.team.age_group
    #   add_breadcrumb @presence.team.name, @presence.team
    #   if @presence.new_record?
    #     add_breadcrumb 'Nieuw'
    #   else
    #     add_breadcrumb @presence.title, @presence
    #   end
    # end
end
