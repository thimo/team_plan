module Activatable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(active: true) }
  end

  def activate
    update(active: true) unless active?
  end

  def deactivate
    update(active: false) if active?
  end

  private

  module ClassMethods
  end

end
