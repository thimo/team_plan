# frozen_string_literal: true

module DefaultUrlOptions
  # Including this file sets the default url options. This is useful for mailers or background jobs

  def default_url_options
    {
      host: host,
      protocol: protocol
    }
  end

  def asset_host
    "#{protocol}://#{host}"
  end

  private

    def host
      Setting["application.hostname"]
    end

    def protocol
      "https"
    end
end
