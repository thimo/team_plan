# frozen_string_literal: true

module FormsHelper
  def date_picker_options(placeholder: "dd-mm-jjjj", help: nil, style_class: "width-sm-25", append: nil)
    {
      placeholder: placeholder,
      help: help,
      data: {
        provide: "datepicker",
        date_format: "dd-mm-yyyy",
        date_language: I18n.locale,
        date_today_highlight: true,
        date_autoclose: true,
        target: "clickable-append.input"
      },
      class: style_class,
      input_group_class: style_class,
      append: append || tag.i(class: "fa fa-calendar-alt", data: { target: "clickable-append.span" }),
      autocomplete: "off"
    }
  end
end
