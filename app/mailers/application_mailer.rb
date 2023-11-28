class ApplicationMailer < ActionMailer::Base
  helper(EmailHelper)

  default from: Rails.application.credentials.email
  layout 'mailer'
end
