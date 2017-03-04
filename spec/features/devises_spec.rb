require 'rails_helper'

RSpec.feature "Devises", type: :feature do
  describe "the signin process", :type => :feature do
    before :each do
      User.create(email: 'user@example.com', password: 'password')
    end

    it "signs me in" do
      visit '/users/sign_in'
      within("#new_user") do
        fill_in 'Email', with: 'user@example.com'
        fill_in 'Wachtwoord', with: 'password'
      end
      click_button 'Inloggen'
      # expect(page).to have_content 'Success'
    end
  end
end
