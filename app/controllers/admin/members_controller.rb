class Admin::MembersController < AdminController
  # before_action :create_user, only: [:new, :create]
  before_action :set_member, only: [:show, :edit, :update]
  before_action :breadcumbs

  def index
    @members = policy_scope(Member).all
  end

  def show; end

  def import
    authorize(Member)
    Member.import(params[:file])

    redirect_to admin_members_path, notice: "Gebruikers zijn geïmporteerd."
  end

  private

  def set_member
    @member = Member.find(params[:id])
    authorize @member
  end

  def member_params
    params.require(:member).permit(:first_name, :middle_name, :last_name, :email, :phone)
  end

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
