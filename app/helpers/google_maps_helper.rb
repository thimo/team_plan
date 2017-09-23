module GoogleMapsHelper
  def google_maps_url(object:, type:, current_user: nil)
    base_url = "#{Setting['google.maps.base_url']}#{type}"

    params = {
      key: Setting['google.maps.api-key']
    }
    case type
    when 'place'
      params.merge!(
        q: object.google_maps_address,
        zoom: 12,
      )
    when 'directions'
      params.merge!(destination: object.google_maps_address)
      if current_user
        member = current_user.members.sportlink_active.first
        params.merge!(origin: "#{member.address},#{member.zipcode} #{member.city}") if member.present?
      else
        params.merge!(origin: "#{Setting['club.sportscenter']},#{Setting['club.address']},#{Setting['club.zip']} #{Setting['club.city']}")
      end
    end

    "#{base_url}?#{params.to_param}"
  end
end
