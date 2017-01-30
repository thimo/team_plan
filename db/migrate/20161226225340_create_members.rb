class CreateMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.date :born_on
      t.string :address
      t.string :zipcode
      t.string :city
      t.string :country
      t.string :phone
      t.string :phone2
      t.string :email
      t.string :email2
      t.integer :gender
      t.string :member_id
      t.string :association_id
      t.boolean :active

      t.timestamps
    end
  end
end
