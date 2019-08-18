# frozen_string_literal: true

module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title = "")
    base_title = "#{Tenant.setting('application_name')} · #{Tenant.setting('club_name')}"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def pnotify_type(message_type)
    case message_type
    when "success", "notice"
      "success"
    when "alert", "warning"
      "notice"
    when "danger", "error"
      "error"
    else
      "info"
    end
  end

  def pnotify_duration(message_type)
    case message_type
    when "success", "notice"
      4000
    when "alert", "warning"
      8000
    when "danger", "error"
      8000
    else
      4000
    end
  end

  def errors_for(model, attribute)
    html_builder = ->(error_message) {
      "<div class='form-text text-muted'>#{model.class.human_attribute_name(attribute)} #{error_message}</div>"
    }
    model.errors[attribute].map { |error_message| html_builder.call(error_message) }.join(" ").html_safe
  end

  def error?(model, attribute)
    model.errors[attribute].present?
  end

  def avatar_url(user)
    return "/eindbaas.jpg" if user.id == 18

    default_url = "svs.defrog.nl/avatar-2-64.png"
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "https://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_url)}"
  end

  def markdown(content)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true,
                                                                   fenced_code_blocks: true)
    @markdown.render(content)
  end

  def true?(obj)
    obj.to_s == "true"
  end

  def replace_param_in_request_path(params)
    uri = URI.parse(request.path)
    query = Rack::Utils.parse_query(uri.query).merge(params)
    uri.query = Rack::Utils.build_query(query)
    uri.to_s
  end

  def flash_message(type, text)
    flash[type] ||= []
    flash[type] << text
  end

  def fa_class
    @fa_class ||= Tenant.setting("fontawesome_integrity").present? ? "fad" : "fa"
  end
end
