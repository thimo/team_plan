require 'rails_helper'

RSpec.feature "Admin::Members", type: :feature do
  scenario "anonymous visits admin/members" do
    member = create(:member)

    visit admin_members_path
    expect(page).to have_current_path new_user_session_path

    visit admin_member_path(member)
    expect(page).to have_current_path new_user_session_path
  end

  scenario "user visits admin/members" do
    member = create(:member)
    user = create(:user)

    login_as(user, scope: :user)

    visit admin_members_path
    expect(page).to have_current_path root_path

    visit admin_member_path(member)
    expect(page).to have_current_path root_path
  end

  scenario "admin visits admin/members" do
    member = create(:member)
    admin = create(:admin)

    logout(:user)
    login_as(admin, scope: :user)

    visit admin_members_path
    ap '#' * 60
    ap page.body
    within ".section-header h3" do
      expect(page).to have_text "Leden"
    end
    expect(page).to have_link href: new_admin_members_import_path

    # Table of members
    within ".page-content" do
      expect(page).to have_content "#{member.first_name} #{member.last_name}"
      expect(page).to have_link href: admin_member_path(member)

      click_link href: admin_member_path(member)
      expect(page).to have_current_path admin_member_path(member)
    end

    within ".page-content" do
      # Breadcrumb
      expect(page).to have_link href: admin_members_path

      click_link href: admin_members_path
      expect(page).to have_current_path admin_members_path
    end
  end
end
