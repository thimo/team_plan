class InjuriesController < ApplicationController
  before_action :set_member, only: [:new, :create]
  before_action :create_injury, only: [:new, :create]
  before_action :set_injury, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show; end

  def new; end

  def create
    if @injury.save
      redirect_to @injury.member, notice: "Blessure is toegevoegd."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @injury.update_attributes(injury_params)
      redirect_to @injury, notice: "Blessure is aangepast."
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @injury.member, notice: "Blessure is verwijderd."
    @injury.destroy
  end

  private

    def set_member
      @member = if @injury.present? && @injury.member.present?
                @injury.member
              else
                Member.find(params[:member_id])
              end
    end

    def create_injury
      @injury = if action_name == 'new'
                  @member.injuries.new(started_on: Time.zone.today)
                else
                  Injury.new(injury_params.merge(user: current_user))
                end
      @injury.member = @member

      authorize @injury
    end

    def set_injury
      @injury = Injury.find(params[:id])
      authorize @injury
    end

    def injury_params
      params.require(:injury).permit(:title, :body, :member_id, :started_on, :ended_on)
    end

    def add_breadcrumbs
      add_breadcrumb @injury.member.name, @injury.member
      if @injury.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @injury.title, @injury
      end
    end
end
