require 'rails_helper'

RSpec.describe Admin::MembersImportController, type: :controller do
  it "should not be implemented" do
    member = create :member

    # index
    expect {
      get admin_members_import_path
    }.to raise_error(NameError)

    # edit
    expect {
      get edit_admin_members_import_path(member)
    }.to raise_error(NameError)

    # update
    expect {
      post admin_members_import_index_path(id: member)
    }.to raise_error(ActionController::UrlGenerationError)

    # destroy
    expect {
      delete admin_members_import_index_path(id: member)
    }.to raise_error(ActionController::UrlGenerationError)
  end
end
