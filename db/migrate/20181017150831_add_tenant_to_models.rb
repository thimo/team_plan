class AddTenantToModels < ActiveRecord::Migration[5.2]
  def change
    %w[age_groups club_data_logs club_data_team_competitions club_data_teams comments competitions
       email_logs favorites field_positions group_members groups injuries logs matches members notes
       org_position_members org_positions play_bans player_evaluations presences roles seasons settings
       soccer_fields team_evaluations team_members teams todos training_schedules trainings user_settings
       users].each do |table|
      add_reference table, :tenant, foreign_key: true
      table.singularize.classify.constantize.update_all(tenant_id: Tenant.first.id)
    end
  end
end
