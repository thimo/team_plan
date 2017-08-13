class AddFuzzyMatching < ActiveRecord::Migration[5.1]
  def change
    enable_extension "fuzzystrmatch"
    enable_extension "unaccent"
    enable_extension "pg_trgm"
  end
end
