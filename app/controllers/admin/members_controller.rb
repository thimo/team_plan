module Admin
  class MembersController < Admin::BaseController
    before_action :add_breadcrumbs

    def index
      @members = policy_scope(Member).asc.filter_results(params.slice(:query))
      @members = params[:inactive] ? @members.inactive : @members.active
      @members = @members.page(params[:page]).per(50)
      authorize @members
    end

    private

    def add_breadcrumbs
      add_breadcrumb "Leden", admin_members_path
      return if @member.nil?

      if @member.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @member.name, @member
      end
    end
  end
end
