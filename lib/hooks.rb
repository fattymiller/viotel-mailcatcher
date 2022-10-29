module Hooks extend self
  autoload :EmailToSms, 'hooks/email_to_sms'

  EmailToSms.start
end