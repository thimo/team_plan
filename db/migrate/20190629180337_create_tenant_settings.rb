class CreateTenantSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :tenant_settings do |t|
      t.references :tenant, foreign_key: true

      t.string :application_name, default: "TeamPlan"
      t.string :application_hostname, default: "teamplan.defrog.nl"
      t.string :application_email, default: "helpdesk@defrog.nl"
      t.string :application_contact_name, default: "Thimo Jansen"
      t.boolean :application_maintenance, default: false
      t.string :application_favicon_url, default: "/favicon.ico"
      t.string :application_sysadmin_email, default: "thimo@teamplanpro.nl"
      t.string :club_name, default: "Defrog"
      t.string :club_name_short, default: "Defrog"
      t.string :club_website, default: "https://teamplan.defrog.nl/"
      t.string :club_sportscenter
      t.string :club_address
      t.string :club_zip
      t.string :club_city
      t.string :club_phone
      t.string :club_relatiecode
      t.string :club_logo_url
      t.string :club_member_administration_email
      t.string :clubdata_urls_competities, default: "https://data.sportlink.com/teams?teamsoort=bond&spelsoort=ve&gebruiklokaleteamgegevens=NEE"
      t.string :clubdata_urls_poulestand, default: "https://data.sportlink.com/poulestand?gebruiklokaleteamgegevens=NEE"
      t.string :clubdata_urls_poule_programma, default: "https://data.sportlink.com/poule-programma?eigenwedstrijden=NEE&gebruiklokaleteamgegevens=NEE&aantaldagen=365&weekoffset=-2"
      t.string :clubdata_urls_pouleuitslagen, default: "https://data.sportlink.com/pouleuitslagen?eigenwedstrijden=NEE&gebruiklokaleteamgegevens=NEE&aantaldagen=30&weekoffset=-4&"
      t.string :clubdata_urls_uitslagen, default: "https://data.sportlink.com/uitslagen?aantalregels=300&gebruiklokaleteamgegevens=NEE&sorteervolgorde=datum-omgekeerd&thuis=JA&uit=JA"
      t.string :clubdata_urls_team_indeling, default: "https://data.sportlink.com/team-indeling?lokaleteamcode=-1&teampersoonrol=ALLES&toonlidfoto=JA"
      t.string :clubdata_urls_wedstrijd_accommodatie, default: "https://data.sportlink.com/wedstrijd-accommodatie"
      t.string :clubdata_urls_afgelastingen, default: "https://data.sportlink.com/afgelastingen?aantalregels=100&weekoffset=-1"
      t.string :clubdata_urls_club_logos, default: "http://bin617.website-voetbal.nl/sites/voetbal.nl/files/knvblogos/"
      t.string :clubdata_client_id
      t.string :fontawesome_version, default: "v5.5.0"
      t.string :fontawesome_integrity
      t.string :google_maps_base_url, default: "https://www.google.com/maps/embed/v1/"
      t.string :google_maps_api_key
      t.string :google_analytics_tracking_id
      t.string :sportlink_members_encoding, default: "utf-8"

      t.timestamps
    end
  end
end
