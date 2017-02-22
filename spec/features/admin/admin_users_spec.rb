require 'rails_helper'

RSpec.feature "Admin::Users", type: :feature do
  scenario "anonymous visits admin/users" do
    user = create(:user)

    visit admin_users_path
    expect(page).to have_current_path new_user_session_path

    visit edit_admin_user_path(user)
    expect(page).to have_current_path new_user_session_path
  end

  scenario "user visits admin/users" do
    user = create(:user)

    login_as(user, scope: :user)

    visit admin_users_path
    expect(page).to have_current_path root_path

    visit edit_admin_user_path(user)
    expect(page).to have_current_path root_path
  end

  scenario "admin visits admin/users" do
    user = create(:user)
    admin = create(:admin)

    login_as(admin, scope: :user)

    visit admin_users_path
    within ".section-header h3" do
      expect(page).to have_text "Gebruikers"
    end
    expect(page).to have_link href: new_admin_user_path

    # Table of users
    within ".page-content" do
      expect(page).to have_content "#{user.name}"
      expect(page).to have_link href: edit_admin_user_path(user)

      click_link href: edit_admin_user_path(user)
      expect(page).to have_current_path edit_admin_user_path(user)
    end

    within ".page-content" do
      # Breadcrumb
      expect(page).to have_link href: admin_users_path

      click_link href: admin_users_path
      expect(page).to have_current_path admin_users_path
    end

    click_link href: new_admin_user_path
    expect(page).to have_current_path new_admin_user_path

    click_button "Opslaan"
    expect(page).to have_current_path admin_users_path
  end
end
