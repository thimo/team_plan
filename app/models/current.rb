# Singleton which acts like a global store accessible from anywhere inside the app
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :session, :request_id, :user_agent, :ip_address, :referer, :path

  def user=(user)
    super
  end
end
