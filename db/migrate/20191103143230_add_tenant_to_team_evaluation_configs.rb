class AddTenantToTeamEvaluationConfigs < ActiveRecord::Migration[6.0]
  def change
    add_reference :team_evaluation_configs, :tenant, foreign_key: true
    TeamEvaluationConfig.update_all(tenant_id: Tenant.first.id)
  end
end
