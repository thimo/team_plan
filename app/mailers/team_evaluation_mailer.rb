class TeamEvaluationMailer < ApplicationMailer
  def invite(user, team_evaluation)
    @user = user
    @team_evaluation = team_evaluation
    mail to: @user.email_with_name, subject: "Invullen teamevaluatie #{@team_evaluation.team.name}"
  end
end
