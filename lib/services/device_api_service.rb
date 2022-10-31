require 'uri'
require 'json'
require 'net/http'

class DeviceApiService
  class << self
    def describe_device(device_name)
      cached = cached_device_description_for(device_name)
      return cached if cached

      payload = fetch_device_description_for(device_name)
      return nil unless payload

      cache_device_description(device_name, payload)
    end

    private

      def cached_device_description_for(device_name)
        @device_description_cache ||= {}
        @device_description_cache[device_name]
      end

      def cache_device_description(device_name, payload)
        @device_description_cache ||= {}
        @device_description_cache[device_name] = payload
      end

      def fetch_device_description_for(device_name)
        uri = URI("https://api.viotelapps.com/devices/#{device_name}/describe")
        response = Net::HTTP.get_response(uri)
        return nil unless response.code.to_i == 200

        JSON.parse(response.body)['data']
      end
  end
end