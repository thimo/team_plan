class CreateJoinTableTeamMemberTrainingSchedule < ActiveRecord::Migration[5.1]
  def change
    create_join_table :team_members, :training_schedules do |t|
      t.index [:team_member_id, :training_schedule_id], name: 'member_schedule'
      t.index [:training_schedule_id, :team_member_id], name: 'schedule_member'
    end
  end
end
