class FixDayForTrainingSchedules < ActiveRecord::Migration[6.0]
  def change
    Tenant.all.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        TrainingSchedule.all.find_each do |ts|
          # Convert days from 'monday = 0' to 'sunday = 0'
          new_day = TrainingSchedule.days[ts.day] + 1
          new_day = 0 if new_day >= 7
          ts.update(day: new_day)
        end
      end
    end
  end
end
