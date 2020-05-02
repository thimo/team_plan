class TeamEvaluationMailer < ApplicationMailer
  def invite(user, members, team_evaluation)
    @team_evaluation = team_evaluation
    @names = members.collect(&:name).join(", ")

    emails = members.collect(&:email_with_name).join(", ")
    from = user.email_with_name || default_from

    if (members = team_evaluation.team.age_group.members).any?
      @salutation_names = members.map(&:name).sort.join(", ")
      @cc = members.map do |member|
        %("#{member.name}" <#{member.preferred_email}>)
      end
    end

    mail(from: from, to: emails, cc: @cc, subject: "Invullen teamevaluatie #{@team_evaluation.team.name}")
  end
end
