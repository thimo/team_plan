module Statussable
  extend ActiveSupport::Concern

  included do
    enum status: {draft: 0, active: 1, archived: 2}
  end

  def status_to_icon_class
    return 'fa-pencil-square-o' if draft?
    return 'fa-check-square-o' if active?
    return 'fa-share-square-o' if archived?
  end

  module ClassMethods
  end
end
