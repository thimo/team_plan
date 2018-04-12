class NotesController < ApplicationController
  before_action :set_team, only: [:new, :create]
  before_action :create_note, only: [:new, :create]
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show; end

  def new; end

  def create
    if @note.save
      redirect_to @note, notice: "Notitie is toegevoegd."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @note.update(note_params)
      redirect_to @note, notice: "Notitie is aangepast."
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @note.team, notice: "Notitie is verwijderd."
    @note.destroy
  end

  private

    def set_team
      @team = @note&.team || Team.find(params[:team_id])
    end

    def create_note
      @note = if action_name == 'new'
                @team.notes.new
              else
                Note.new(note_params.merge(user: current_user))
              end
      @note.team = @team

      authorize @note
    end

    def set_note
      @note = Note.find(params[:id])
      authorize @note
    end

    def note_params
      params.require(:note).permit(:title, :body, :team_id, :member_id, :visibility)
    end

    def add_breadcrumbs
      add_breadcrumb "#{@note.team.age_group.season.name}", @note.team.age_group.season
      add_breadcrumb @note.team.age_group.name, @note.team.age_group
      add_breadcrumb @note.team.name, @note.team
      if @note.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @note.title, @note
      end
    end
end
