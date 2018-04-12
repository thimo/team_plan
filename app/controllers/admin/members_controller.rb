class Admin::MembersController < Admin::BaseController
  before_action :add_breadcrumbs

  def index
    @members = policy_scope(Member).asc.filter(params.slice(:query))
    @members = params[:inactive] ? @members.sportlink_inactive : @members.sportlink_active
    @members = @members.page(params[:page]).per(50)
  end

  private

    def add_breadcrumbs
      add_breadcrumb "Leden", admin_members_path
      unless @member.nil?
        if @member.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @member.name, @member
        end
      end
    end
end
