# frozen_string_literal: true

class PresencesController < ApplicationController
  before_action :set_parent, only: [:index]
  before_action :set_presence, only: [:update]

  def index
    @team = Team.find(params[:team]) if params[:team]
    @presences = policy_scope(@parent.find_or_create_presences(@team)).asc
  end

  def update
    @presence.update(presence_params)
    @present_count = @presence.presentable.presences.present.size
  end

  private

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

    def presence_params
      params.require(:presence).permit(:is_present, :on_time, :signed_off, :remark)
    end
end
