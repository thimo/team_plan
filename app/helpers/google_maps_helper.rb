# frozen_string_literal: true

module GoogleMapsHelper
  def google_maps_url(object:, type:, user: nil, zoom: 12)
    base_url = "#{Tenant.setting('google_maps_base_url')}#{type}"

    params = {
      key: Tenant.setting("google_maps_api_key")
    }
    case type
    when "place"
      params[:q] = object.google_maps_address
      params[:zoom] = zoom
    when "directions"
      params[:destination] = object.google_maps_address
      if user.present?
        member = user.members.active.first
        params[:origin] = "#{member.address},#{member.zipcode} #{member.city}" if member.present?
      else
        params[:origin] = "#{Tenant.setting('club_sportscenter')},#{Tenant.setting('club_address')},#{Tenant.setting('club_zip')} #{Tenant.setting('club_city')}"
      end
    end

    "#{base_url}?#{params.to_param}"
  end
end
