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

  def transmit_status(new_status, old_status = nil)
    return if new_status == old_status

    update_columns(status: self.class.statuses[new_status]) if self.status != new_status
    update_columns(ended_on: Date.today) if user_invoked_archivation?(old_status)
    update_columns(ended_on: nil) if unarchived_with_end_date?

    if respond_to? :status_children
      status_children.each do |child|
        unless child.archived? && child.ended_on.present?
          child.transmit_status(new_status)
        end
      end
    end
  end

  private

    def user_invoked_archivation?(old_status)
      old_status.present? && self.archived?
    end

    def unarchived_with_end_date?
      (draft? || active?) && ended_on.present?
    end

  module ClassMethods
  end

end
