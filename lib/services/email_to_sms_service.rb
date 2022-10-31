require 'mail_catcher/bus'
require 'nokogiri'
require 'net/http'
require 'uri'

class EmailToSmsService
  class << self
    def publish(message)
      mail = Mail.new(message[:source])
      body_parts = if mail.html_part
        body_parts_from_html(mail.html_part.decoded)
      else
        body_parts_from_html(mail.decoded)
      end

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
          'message' => body_parts[:message],
          'test' => true
        }

        puts "Relaying to '#{recipient}'"
        post_form(body, headers)
      end
    end

    private

      def body_parts_from_html(html)
        html_doc = Nokogiri::HTML(html)

        # if this doesnt contain a viot number, should we use generic text?
        message_part = html_doc.css('p').first
        link = html_doc.css('a').detect { |n| n.inner_text == 'View your Alert rule' }

        # payload = if device_name_parts = message_part.scan(/viot[\d]{5}/)
        #   DeviceApiService.describe_device(device_name_parts.first)
        # end

        {
          message: message_part && message_part.inner_text.strip,
          link: link && link['href']
        }
      end

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