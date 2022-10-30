require 'mail_catcher/bus'
require 'net/http'
require 'uri'

class EmailToSmsService
  class << self
    def publish(message)
      message[:recipients].each do |recipient_email|
        recipient = recipient_email.split('@')[0].to_s.scan(/\d+/).first

        headers = {
          'user' => MailCatcher.options[:sms_api_user],
          'Api-Key' => MailCatcher.options[:sms_api_key],
          'Content-Type' => 'application/x-www-form-urlencoded'
        }

        body = {
          'sender' => MailCatcher.options[:sms_api_sender],
          'to' => recipient,
          'message' => Mail.new(message[:source]).text_part.decoded,
          'test' => true
        }

        puts "Relaying to '#{recipient}'"
        post_form(body, headers)
      end
    end

    private

    def post_form(body, headers)
      uri = URI('https://www.5centsms.com.au/api/v4/sms')
      http = Net::HTTP.new(uri.host, 443)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(body)

      (headers || {}).each do |key, value|
        request[key] = value
      end

      http.request(request)
    end
  end
end