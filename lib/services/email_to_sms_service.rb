require 'mail_catcher/bus'
require 'net/http'
require 'uri'

class EmailToSmsService
  class << self
    def publish(message)
      message[:recipients].each do |recipient|
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
        post_form('https://www.5centsms.com.au/api/v4/sms', body, headers)
      end
    end

    private

      def post_form(url, body, headers)
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)

        request.set_form_data(body)

        (headers || {}).each do |key, value|
          request[key] = value
        end

        http.request(request)
      end
  end
end