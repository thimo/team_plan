class CleanupColumnsInMembers < ActiveRecord::Migration[5.2]
  def change
    remove_column :members, :place_of_birth, :string
    remove_column :members, :country_of_birth, :string
    remove_column :members, :nationality, :string
    remove_column :members, :nationality_2, :string
    remove_column :members, :id_type, :string
    remove_column :members, :id_number, :string
    remove_column :members, :contact_via_parent, :string
    remove_column :members, :bank_account_type, :string
    remove_column :members, :bank_account_number, :string
    remove_column :members, :bank_bic, :string
    remove_column :members, :bank_authorization, :string
    remove_column :members, :contribution_category, :string
  end
end
