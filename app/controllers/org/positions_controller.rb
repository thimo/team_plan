class Org::PositionsController < Org::BaseController
  before_action :create_org_position, only: [:new, :create]
  before_action :set_org_position, only: [:show, :edit, :update, :destroy]
  before_action :set_parent_list, only: [:new, :create, :edit, :update]
  before_action :add_breadcrumbs

  def index
    @org_positions = policy_scope(OrgPosition).active.arrange(order: :name)
  end

  def show
  end

  def new
  end

  def create
    if @org_position.save
      redirect_to @org_position, notice: 'Positie is toegevoegd.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @org_position.update(permitted_attributes(@org_position))
      redirect_to @org_position, notice: 'Positie is aangepast.'
    else
      render :edit
    end
  end

  private

    def create_org_position
      started_on = Date.current
      @org_position = if action_name == 'new'
                        OrgPosition.new(started_on: started_on)
                      else
                        OrgPosition.new(permitted_attributes(OrgPosition.new).merge(started_on: started_on))
                      end

      authorize @org_position
    end

    def set_org_position
      @org_position = OrgPosition.find(params[:id])
      authorize @org_position
    end

    def add_breadcrumbs
      # add_breadcrumb "Organisatie", org_path
      unless @org_position.nil?
        if @org_position.new_record?
          add_breadcrumb 'Nieuw'
        else
          add_breadcrumb @org_position.name.to_s, @org_position
        end
      end
    end

    def set_parent_list
      @org_positions = OrgPosition.active.arrange_as_array({order: 'name'}, @org_position.possible_parents)
    end

end
