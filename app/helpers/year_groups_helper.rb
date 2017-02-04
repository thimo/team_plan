module YearGroupsHelper
  def year_of_birth_range(year_group)
    range = ""
    unless year_group.year_of_birth_from.nil? && year_group.year_of_birth_to.nil?
      if year_group.year_of_birth_from.nil?
        range += "tot "
      else
        range += "#{year_group.year_of_birth_from}"
      end
      unless year_group.year_of_birth_from.nil? || year_group.year_of_birth_to.nil?
        range += " - "
      end
      if year_group.year_of_birth_to.nil?
        range += " en ouder"
      else
        range += "#{year_group.year_of_birth_to}"
      end
    end
    return range
  end
end
