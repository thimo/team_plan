module Statussable
  extend ActiveSupport::Concern

  included do
    enum status: {draft: 0, active: 1, archived: 2}
  end

  def status_to_label
    title = ended_on.present? ? "Per #{I18n.l(ended_on, format: :long)}" : ''
    return "<span class=\"label #{color_class_for_status}\" title=\"#{title}\">#{status_i18n}</span>"
  end

  def transmit_status(new_status, old_status = nil)
    return if new_status == old_status

    update_columns(status: self.class.statuses[new_status]) if self.status != new_status
    unless self.class == Season
      update_columns(ended_on: Time.zone.today) if user_invoked_archivation?(old_status)
      update_columns(ended_on: nil) if unarchived_with_end_date?
    end

    if respond_to? :status_children
      status_children.each do |child|
        unless child.archived? && child.ended_on.present?
          child.transmit_status(new_status)
        end
      end
    end
  end

  def color_class_for_status
    return color_class = 'label-warning' if draft?
    return color_class = 'label-success' if active?
    return color_class = 'label-light-grey' if archived?
  end

  def to_archive
    update(status: self.class.statuses[:archived]) unless self.archived?
  end

  def deactivate
    to_archive
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
