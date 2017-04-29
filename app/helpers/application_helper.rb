module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "#{Setting['application.name']} · #{Setting['company.name']}"
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end

  def notie_type(message_type)
    # 1 - success, 2 - warning, 3 - error, 4 - info
    case message_type
    when "success", "notice"
      1
    when "alert", "warning"
      2
    when "danger", "error"
      3
    else
      4
    end
  end

  def errors_for(model, attribute)
    html_builder = lambda {|error_message| "<div class='form-text text-muted'>#{model.class.human_attribute_name(attribute)} #{error_message}</div>" }
    model.errors[attribute].map { |error_message|  html_builder.call(error_message) }.join(' ').html_safe
  end

  def has_error(model, attribute)
    not model.errors[attribute].blank?
  end

  def avatar_url(user)
    # default_url = "#{root_url}startui/img/avatar-2-32.png"
    default_url = "svs.defrog.nl/startui/img/avatar-2-32.png"
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "https://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_url)}"
  end

  def markdown(content)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true, fenced_code_blocks: true)
    @markdown.render(content)
  end
end
