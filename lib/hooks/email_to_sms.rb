require 'mail_catcher/bus'
require 'net/http'
require 'uri'

SMS_API_USER = ENV.fetch('SMS_API_USER')
SMS_API_KEY = ENV.fetch('SMS_API_KEY')
SMS_API_SENDER = ENV.fetch('SMS_API_SENDER')

module Hooks::EmailToSms
  def publish(message)
    message[:recipients].each do |recipient|
      headers = { 'user' => SMS_API_USER, 'Api-Key' => SMS_API_KEY }
      body = {
        'sender' => SMS_API_SENDER,
        'to' => recipient,
        'message' => Mail.new(message[:source]).decoded,
        'test' => true
      }

      puts "Relaying to '#{recipient}'"

      Net::HTTP.post_form(URI('https://www.5centsms.com.au/api/v4/sms'), body, headers)
    end
  end
end