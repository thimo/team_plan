module SortHelper
  # Sort array of objects in an human expected way
  def human_sort(objects = [], attribute = "")
    return [] if attribute.blank? || objects.blank?

    objects = objects.sort_by { |obj|
      obj.send(attribute).to_s.split(/(\d+)/).map { |e|
        [e.to_i, e]
      }
    }
  end

end
