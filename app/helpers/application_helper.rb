module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = I18n.t('company.name')
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
    when "alert"
      2
    when "danger", "error"
      3
    else
      4
    end
  end
end
