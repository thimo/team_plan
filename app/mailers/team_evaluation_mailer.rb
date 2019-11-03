# frozen_string_literal: true

class TeamEvaluationMailer < ApplicationMailer
  def invite(members, team_evaluation)
    @team_evaluation = team_evaluation
    @names = members.collect(&:name).join(", ")
    emails = members.collect(&:email_with_name).join(", ")
    mail(from: default_from, to: emails, subject: "Invullen teamevaluatie #{@team_evaluation.team.name}")
  end
end
