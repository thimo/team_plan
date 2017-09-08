class FillTeamForPresences < ActiveRecord::Migration[5.1]
  def change
    Presence.where(team: nil).each do |presence|
      presence.update_columns(team_id: presence.member.active_team.id)
    end
  end
end
