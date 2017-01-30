class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder

  def render
    return '' unless @elements.size > 0 # fail gracefully if no breadcrumbs
    regular_elements = @elements.dup
    active_element = regular_elements.pop

    @context.content_tag(:div, class: 'container') do
      @context.content_tag(:ol, class: 'breadcrumb') do
        regular_elements.map do |element|
          render_regular_element(element)
        end.join.html_safe + render_active_element(active_element).html_safe
      end
    end
  end

  def render_regular_element(element)
    @context.content_tag(:li, class: 'breadcrumb-item') do
      @context.link_to(compute_name(element), compute_path(element),
                       element.options.merge(class: ''))
    end
  end

  def render_active_element(element)
    @context.content_tag(:li, class: 'active breadcrumb-item') do
      compute_name(element)
    end
  end
end
