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
      Tenant.setting("application_hostname")
    end

    def protocol
      "https"
    end
end
