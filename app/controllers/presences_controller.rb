class PresencesController < ApplicationController
  before_action :set_parent, only: [:index]
  before_action :set_presence, only: [:show, :edit, :update, :destroy]

  def index
    @presences = policy_scope(@parent.find_or_create_presences).asc
  end

  def update
    if @presence.update_attributes(presence_params)
      @presence.set_presentable_user_modified
      @present_count = @presence.presentable.presences.present.size
      # redirect_to @presence, notice: "Notitie is aangepast."
    else
      # render 'edit'
    end
  end

  private

    def set_parent
      @parent = if params[:training_id]
         Training.find(params[:training_id])
       elsif params[:club_data_match_id]
         ClubDataMatch.find(params[:club_data_match_id])
       elsif params[:match_id]
         Match.find(params[:match_id])
       end
    end

    def set_presence
      @presence = Presence.find(params[:id])
      authorize @presence
    end

    def presence_params
      params.require(:presence).permit(:present, :on_time, :signed_off, :remark)
    end

end
