#
# Usage:
#  rails runner scripts/email_test.rb
#
ActionMailer::Base.mail(
  from: Settings.devise_mailer_sender,
  to: Settings.support_email,
  subject: 'Test from TH',
  body: 'Test from TH'
).deliver_now
