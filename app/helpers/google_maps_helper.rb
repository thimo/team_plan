# frozen_string_literal: true

module GoogleMapsHelper
  def google_maps_url(object:, type:, user: nil, zoom: 12)
    base_url = "#{ActsAsTenant.current_tenant.settings['google.maps.base_url']}#{type}"

    params = {
      key: ActsAsTenant.current_tenant.settings["google.maps.api-key"]
    }
    case type
    when "place"
      params[:q] = object.google_maps_address
      params[:zoom] = zoom
    when "directions"
      params[:destination] = object.google_maps_address
      if user.present?
        member = user.members.sportlink_active.first
        params[:origin] = "#{member.address},#{member.zipcode} #{member.city}" if member.present?
      else
        params[:origin] = "#{ActsAsTenant.current_tenant.settings['club.sportscenter']},#{ActsAsTenant.current_tenant.settings['club.address']},#{ActsAsTenant.current_tenant.settings['club.zip']} #{ActsAsTenant.current_tenant.settings['club.city']}"
      end
    end

    "#{base_url}?#{params.to_param}"
  end
end
