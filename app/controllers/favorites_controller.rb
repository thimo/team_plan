class FavoritesController < ApplicationController
  before_action :set_favorite, only: [:destroy]
  before_action :load_favorable, only: [:create]

  def create
    @favorite = Favorite.new(favorable: @favorable, user: current_user)
    authorize @favorite
    if @favorite.save
      redirect_to :back, notice: "Favoriet is toegevoegd."
    else
      redirect_to :back, warning: "Favoriet is niet toegevoegd."
    end
  end

  def destroy
    @favorite.destroy
    redirect_to :back, notice: "Favoriet is verwijderd."
  end

  private
    def set_favorite
      @favorite = Favorite.find(params[:id])
      authorize @favorite
    end

    def load_favorable
      resource, id = request.path.split('/')[1, 2]
      @favorable = resource.singularize.classify.constantize.find(id)
    end

    def favorite_params
      params.require(:favorite)
    end
end
