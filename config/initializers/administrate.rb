Administrate::Engine.add_stylesheet("administrate_customizations")

require "administrate/search"

# Administrate 1.0.0.beta3 still uses String#mb_chars in search query values.
# Rails 8.1 deprecates that API ahead of removal in Rails 8.2.
module AdministrateSearchWithoutDeprecatedMultibyte
  private

  def query_values
    fields_count = search_attributes.sum do |attr|
      searchable_fields(attr).count
    end

    ["%#{term.downcase}%"] * fields_count
  end
end

Administrate::Search.prepend(AdministrateSearchWithoutDeprecatedMultibyte)
