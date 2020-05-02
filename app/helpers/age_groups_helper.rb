module AgeGroupsHelper
  def year_of_birth_range(age_group)
    range = ""

    if age_group.year_of_birth_from || age_group.year_of_birth_to
      range += if age_group.year_of_birth_from.nil?
                 "tot "
               else
                 age_group.year_of_birth_from.to_s
               end

      unless age_group.year_of_birth_from == age_group.year_of_birth_to
        range += " - " unless age_group.year_of_birth_from.nil? || age_group.year_of_birth_to.nil?

        range += if age_group.year_of_birth_to.nil?
                   " en jonger"
                 else
                   age_group.year_of_birth_to.to_s
                 end
      end
    end

    range
  end
end
