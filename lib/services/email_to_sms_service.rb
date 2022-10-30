require 'mail_catcher/bus'
require 'net/http'
require 'uri'

module EmailToSmsService
  def publish(message)
    message[:recipients].each do |recipient|
      headers = { 'user' => MailCatcher.options[:sms_api_user], 'Api-Key' => MailCatcher.options[:sms_api_key] }
      body = {
        'sender' => MailCatcher.options[:sms_api_sender],
        'to' => recipient,
        'message' => Mail.new(message[:source]).decoded,
        'test' => true
      }

      puts "Relaying to '#{recipient}'"

      Net::HTTP.post_form(URI('https://www.5centsms.com.au/api/v4/sms'), body, headers)
    end
  end
end