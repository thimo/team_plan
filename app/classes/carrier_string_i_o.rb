# frozen_string_literal: true

class CarrierStringIO < StringIO
  def original_filename
    "photo.jpg"
  end

  def content_type
    "image/jpeg"
  end
end
