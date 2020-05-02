module Activatable
  extend ActiveSupport::Concern

  included do
    scope :active,   -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
  end

  def activate
    update(active: true) unless active?
  end

  def deactivate
    update(active: false) if active?
  end

  def inactive?
    !active?
  end

  def archived?
    inactive?
  end

  private

    module ClassMethods
    end
end
