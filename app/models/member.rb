class Member < ApplicationRecord
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :comments, as: :commentable
  belongs_to :user

  # validates_presence_of :first_name, :last_name, :email, :phone

  def name
    "#{first_name} #{middle_name} #{last_name}".squish
  end

  def self.import(file)
    CSV.foreach(file.path, :headers => true,
                           :header_converters => lambda { |h| I18n.t("member.import.#{h.downcase.gsub(' ', '_')}") }
                           ) do |row|
      row_hash = row.to_hash
      association_number = row_hash["association_number"]
      member = Member.find_or_initialize_by(association_number: association_number)

      row_hash.each do |k, v|
        member.send("#{k}=", v) if Member.column_names.include?(k) && !v.blank?
      end

      member.imported_at = DateTime.now
      member.save!
    end
  end
end
