class MailLoggerObserver
  def self.delivered_email(message)
    body = if message.html_part&.present?
             message.html_part.body.raw_source
           else
             message.body.raw_source
           end
    body_plain = message.text_part ? message.text_part.body.raw_source : ""

    user = User.find_by(email: message.to.first)
    EmailLog.create!(from:       message.From.value,
                     to:         message.To.value,
                     subject:    message.Subject.value,
                     body:       body,
                     body_plain: body_plain,
                     user_id:    user ? user.id : nil)
  end
end
