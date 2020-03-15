# frozen_string_literal: true

class TenantSettingPolicy < ApplicationPolicy
  def update?
    @user.role?(Role::BEHEER_SETTINGS)
  end

  def permitted_attributes
    # TODO: Split attributes for different levels of access, like this:
    # attributes << :status if set_status?
    attributes = [
      :application_name,
      :application_hostname,
      :application_email,
      :application_contact_name,
      :application_maintenance,
      :application_favicon_url,
      :application_sysadmin_email,
      :club_name,
      :club_name_short,
      :club_website,
      :club_sportscenter,
      :club_address,
      :club_zip,
      :club_city,
      :club_phone,
      :club_relatiecode,
      :club_logo_url,
      :club_member_administration_email,
      :clubdata_urls_competities,
      :clubdata_urls_poulestand,
      :clubdata_urls_poule_programma,
      :clubdata_urls_pouleuitslagen,
      :clubdata_urls_uitslagen,
      :clubdata_urls_team_indeling,
      :clubdata_urls_wedstrijd_accommodatie,
      :clubdata_urls_afgelastingen,
      :clubdata_urls_club_logos,
      :clubdata_client_id,
      :fontawesome_kit_nr,
      :google_maps_base_url,
      :google_maps_api_key,
      :google_analytics_tracking_id,
      :voetbalassist_referee_url,
      local_teams_always_allowed_in_team: [],
      local_teams_warning_sportlink: []
    ]
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(Role::BEHEER_SETTINGS)

      scope.none
    end
  end
end
