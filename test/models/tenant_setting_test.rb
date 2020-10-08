# == Schema Information
#
# Table name: tenant_settings
#
#  id                                   :bigint           not null, primary key
#  application_contact_name             :string           default("Thimo Jansen")
#  application_email                    :string           default("helpdesk@defrog.nl")
#  application_favicon_url              :string           default("/favicon.ico")
#  application_hostname                 :string           default("teamplan.defrog.nl")
#  application_maintenance              :boolean          default(FALSE)
#  application_name                     :string           default("TeamPlan")
#  application_sysadmin_email           :string           default("thimo@teamplanpro.nl")
#  club_address                         :string
#  club_city                            :string
#  club_logo_url                        :string
#  club_member_administration_email     :string
#  club_name                            :string           default("Defrog")
#  club_name_short                      :string           default("Defrog")
#  club_phone                           :string
#  club_relatiecode                     :string
#  club_sportscenter                    :string
#  club_website                         :string           default("https://teamplan.defrog.nl/")
#  club_zip                             :string
#  clubdata_urls_afgelastingen          :string           default("https://data.sportlink.com/afgelastingen?aantalregels=100&weekoffset=-1")
#  clubdata_urls_club_logos             :string           default("https://logoapi.voetbal.nl/logo.php?clubcode=%relatiecode%")
#  clubdata_urls_competities            :string           default("https://data.sportlink.com/teams?teamsoort=bond&spelsoort=ve&gebruiklokaleteamgegevens=NEE")
#  clubdata_urls_poule_programma        :string           default("https://data.sportlink.com/poule-programma?eigenwedstrijden=NEE&gebruiklokaleteamgegevens=NEE&aantaldagen=365&weekoffset=-2")
#  clubdata_urls_poulestand             :string           default("https://data.sportlink.com/poulestand?gebruiklokaleteamgegevens=NEE")
#  clubdata_urls_pouleuitslagen         :string           default("https://data.sportlink.com/pouleuitslagen?eigenwedstrijden=NEE&gebruiklokaleteamgegevens=NEE&aantaldagen=30&weekoffset=-4&")
#  clubdata_urls_team_indeling          :string           default("https://data.sportlink.com/team-indeling?lokaleteamcode=-1&teampersoonrol=ALLES&toonlidfoto=JA")
#  clubdata_urls_uitslagen              :string           default("https://data.sportlink.com/uitslagen?aantalregels=300&gebruiklokaleteamgegevens=NEE&sorteervolgorde=datum-omgekeerd&thuis=JA&uit=JA")
#  clubdata_urls_wedstrijd_accommodatie :string           default("https://data.sportlink.com/wedstrijd-accommodatie")
#  fontawesome_kit_nr                   :string
#  google_maps_api_key                  :string
#  google_maps_base_url                 :string           default("https://www.google.com/maps/embed/v1/")
#  last_import_members                  :datetime
#  local_teams_always_allowed_in_team   :string           default([]), is an Array
#  local_teams_warning_sportlink        :string           default([]), is an Array
#  sportlink_members_encoding           :string           default("utf-8")
#  voetbalassist_referee_url            :string
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  clubdata_client_id                   :string
#  google_analytics_tracking_id         :string
#  tenant_id                            :bigint
#
# Indexes
#
#  index_tenant_settings_on_tenant_id  (tenant_id)
#
require "test_helper"

class TenantSettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
