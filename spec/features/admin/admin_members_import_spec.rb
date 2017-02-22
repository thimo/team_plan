require 'rails_helper'

RSpec.feature "Admin::MembersImport", type: :feature do
  scenario "anonymous visits admin/members_import" do
    visit new_admin_members_import_path
    expect(page).to have_current_path new_user_session_path
  end

  scenario "user visits admin/members_import" do
    user = create(:user)

    login_as(user, scope: :user)

    visit new_admin_members_import_path
    expect(page).to have_current_path root_path
  end

  scenario "admin visits admin/members_import" do
    admin = create(:admin)

    login_as(admin, scope: :user)

    visit new_admin_members_import_path
    within ".section-header h3" do
      expect(page).to have_text "Importeer leden"
    end

    click_button "Importeren"
    expect(page).to have_current_path admin_members_import_index_path

    # Import sportlink file
    visit new_admin_members_import_path
    expect {
      attach_file("file", Rails.root + "spec/fixtures/members_import.csv")
      click_button "Importeren"
    }.to change { Member.count }.by(1)

    # Re-import
    visit new_admin_members_import_path
    expect {
      attach_file("file", Rails.root + "spec/fixtures/members_import.csv")
      click_button "Importeren"
    }.not_to change { Member.count }

    # Member should be in members list
    visit admin_members_path
    expect(page).to have_content "Andreas Jansen"
  end
end
