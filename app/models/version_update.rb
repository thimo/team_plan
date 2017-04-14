class VersionUpdate < ApplicationRecord
  validates_presence_of :released_at, :name, :body
end
