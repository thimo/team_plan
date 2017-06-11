class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  def show; end

  def create
    @note = Note.new(note_params.merge(user: current_user))
    authorize @note
    if @note.save
      redirect_to @note.team, notice: "Notitie is toegevoegd."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @note.update_attributes(note_params)
      redirect_to @note.team, notice: "Notitie is aangepast."
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @note.team, notice: "Notitie is verwijderd."
    @note.destroy
  end

  private
    def set_note
      @note = Note.find(params[:id])
      authorize @note
    end

    def note_params
      params.require(:note).permit(:title, :body, :team_id, :member_id, :visibility)
    end
end
