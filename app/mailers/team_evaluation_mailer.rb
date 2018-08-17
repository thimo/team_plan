# frozen_string_literal: true

class TeamEvaluationMailer < ApplicationMailer
  def invite(users, team_evaluation)
    @users = users
    @team_evaluation = team_evaluation
    @names = @users.collect(&:name).join(", ")
    emails = @users.collect(&:email_with_name).join(", ")
    mail to: emails, subject: "Invullen teamevaluatie #{@team_evaluation.team.name}"
  end
end
