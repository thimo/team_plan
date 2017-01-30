class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :members

  # Add conditional validation on first_name and last_name, not executed for devise
  validates_presence_of :email

  enum role: {role_member: 0, role_admin: 1}

  # Setter
  def name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def name
    if first_name.blank? && last_name.blank?
      email
    else
      "#{first_name} #{middle_name} #{last_name}".squish
    end
  end

  def email_with_name
    %("#{self.name}" <#{self.email}>)
  end

end
