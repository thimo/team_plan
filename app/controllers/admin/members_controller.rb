class Admin::MembersController < AdminController
  before_action :breadcumbs

  def index
    @members = policy_scope(Member).asc.filter(params.slice(:query))
  end

  private

    def breadcumbs
      add_breadcrumb 'Leden', admin_members_path
      unless @member.nil?
        if @member.new_record?
          add_breadcrumb 'Nieuw'
        else
          add_breadcrumb @member.name, @member
        end
      end
    end
end
