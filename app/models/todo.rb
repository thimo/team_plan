# == Schema Information
#
# Table name: todos
#
#  id            :bigint           not null, primary key
#  body          :text
#  ended_on      :date
#  finished      :boolean          default(FALSE)
#  started_on    :date
#  todoable_type :string
#  waiting       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tenant_id     :bigint
#  todoable_id   :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_todos_on_tenant_id                      (tenant_id)
#  index_todos_on_todoable_type_and_todoable_id  (todoable_type,todoable_id)
#  index_todos_on_user_id                        (user_id)
#
class Todo < ApplicationRecord
  acts_as_tenant :tenant
  belongs_to :user
  belongs_to :todoable, polymorphic: true, optional: true
  has_paper_trail

  scope :asc,      -> { order(created_at: :asc) }
  scope :desc,     -> { order(created_at: :desc) }
  scope :unfinished, -> { where(finished: false) }
  scope :finished, -> { where(finished: true) }
  scope :active,   -> { where(started_on: nil).or(where("started_on <= ?", Time.zone.today)) }
  scope :defered,  -> { where("started_on > ?", Time.zone.today) }

  def due?
    ended_on.present? && ended_on < Time.zone.now
  end

  def defered?
    started_on.present? && started_on > Time.zone.now
  end
end
