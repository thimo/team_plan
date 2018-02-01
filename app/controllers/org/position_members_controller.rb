class Org::PositionMembersController < Org::BaseController
  before_action :create_team_member, only: [:new, :create]
  before_action :set_position_member, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs, only: [:new, :edit]

  def new
    @team = Team.find(params[:team_id])

    @position_member = @team.position_members.new

    authorize @position_member
  end

  def create
    if params[:age_group_id].present?
      # Action from member allocations
      @age_group = AgeGroup.find(params[:age_group_id])

      if params[:position_member_id].present?
        # Remove player from previous team
        @position_member = OrgPositionMember.find(params[:position_member_id])
        authorize @position_member
        @position_member.deactivate
      end

      @position_member = OrgPositionMember.new(permitted_attributes(OrgPositionMember.new))
      authorize @position_member

      if @position_member.save
        @position_member.member.logs << Log.new(body: "Toegevoegd aan #{@position_member.team.name}.", user: current_user)
        flash[:success] = "#{@position_member.member.name} is aan #{@position_member.team.name} toegevoegd"
      else
        flash[:alert] = "Er is iets mis gegaan, de speler is niet toegevoegd"
      end

      respond_to do |format|
        format.html {
          redirect_to age_group_member_allocations_path(@age_group)
        }
        format.js {
          @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
          render "create"
        }
      end
    else
      @team = Team.find(params[:team_id])
      @position_member = OrgPositionMember.new(permitted_attributes(OrgPositionMember.new(team: @team)))
      @position_member.team ||= @team
      authorize @position_member

      # @position_member.initial_draft? does not seem to work here
      if @position_member.initial_status != 'initial_draft'
        # By default use team's status, otherwise use default 'status' value (draft)
        @position_member.status = @team.status
      end

      if @position_member.save
        return redirect_to @team
      else
        render :new
      end
    end
  end

  def edit;end

  def update
    old_status = @position_member.status

    if @position_member.update_attributes(permitted_attributes(@position_member))
      @position_member.transmit_status(@position_member.status, old_status)

      redirect_to @position_member.team, notice: 'Teamgenoot is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    # TODO check if this works correctly for positions
    @position_member.deactivate(user: current_user)

    flash[:success] = "#{@position_member.member.name} is verwijderd uit #{@position_member.team.name}."
    redirect_to back_url
  end

  private

    def set_position_member
      @position_member = OrgPositionMember.find(params[:id])
      authorize @position_member
    end

    def add_breadcrumbs
      add_breadcrumb "#{@position_member.team.age_group.season.name}", @position_member.team.age_group.season
      add_breadcrumb @position_member.team.age_group.name, @position_member.team.age_group
      add_breadcrumb @position_member.team.name, @position_member.team
      if @position_member.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @position_member.member.name, @position_member
      end
    end

end
