class AddImportColumnsToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :status, :string
    add_column :members, :full_name_2, :string
    add_column :members, :place_of_birth, :string
    add_column :members, :country_of_birth, :string
    add_column :members, :nationality, :string
    add_column :members, :nationality_2, :string
    add_column :members, :id_type, :string
    add_column :members, :id_number, :string
    add_column :members, :lasts_change_at, :date
    add_column :members, :privacy_level, :string
    add_column :members, :street, :string
    add_column :members, :house_number, :string
    add_column :members, :house_number_addition, :string
    add_column :members, :phone_home, :string
    add_column :members, :contact_via_parent, :string
    add_column :members, :phone_parent, :string
    add_column :members, :phone_parent_2, :string
    add_column :members, :email_parent, :string
    add_column :members, :email_parent_2, :string
    add_column :members, :bank_account_type, :string
    add_column :members, :bank_account_number, :string
    add_column :members, :bank_bic, :string
    add_column :members, :bank_authorization, :string
    add_column :members, :contribution_category, :string
    add_column :members, :registered_at, :string
    add_column :members, :deregistered_at, :string
    add_column :members, :member_since, :string
    add_column :members, :age_category, :string
    add_column :members, :local_teams, :string
    add_column :members, :club_sports, :string
    add_column :members, :association_sports, :string
  end
end
