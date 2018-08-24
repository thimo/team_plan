# frozen_string_literal: true

module FormsHelper
  def date_picker_options(placeholder: "dd-mm-jjjj", help: nil, style_class: "width-sm-25")
    {
      placeholder: placeholder,
      help: help,
      data: {
        provide: "datepicker",
        date_format: "dd-mm-yyyy",
        date_language: "nl",
        date_today_highlight: true,
        date_autoclose: true
      },
      class: style_class
    }
  end
end
