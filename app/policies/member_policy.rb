class MemberPolicy < AdminPolicy
  def show?
    true
  end

  def import?
    process_import?
  end

  def process_import?
    create? && update?
  end

  def show_favorite?
    @user.admin? || @user.club_staff?
  end

  def show_private_data?
    @user.admin? ||
    @user.club_staff? ||
    @user.team_member_for?(@record)
  end

  def show_conduct?
    @user.admin? ||
    @user.club_staff?
  end

  def show_sportlink_status?
    @user.admin? ||
      @user.club_staff?
  end

  def show_todos?
    show_private_data?
  end

  def show_evaluations?
    @user.admin? ||
    @user.club_staff? ||
    @user.team_staff_for?(@record) ||
    @user.member?(@record)
  end

  def show_comments?
    show_evaluations? ||
    @user.member?(@record)
  end

  def show_injuries?
    show_evaluations?
  end

  def show_new_members?
    @user.admin? ||
    @user.club_staff?
  end

  def show_login?
    create_login?
  end

  def resend_password?
    create_login?
  end

  def create_login?
    @user.admin? ||
    @user.club_staff?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
