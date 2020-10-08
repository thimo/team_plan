class ChangeDefaultForClubdataUrlsClubLogos < ActiveRecord::Migration[6.0]
  def change
    change_column :tenant_settings, :clubdata_urls_club_logos, :string, default: "https://logoapi.voetbal.nl/logo.php?clubcode=%relatiecode%"
  end
end
