
class AzureEventHubsHttpSender
  def initialize(connection_string, hub_name, expiry=3600,proxy_addr='',proxy_port=3128,open_timeout=60,read_timeout=60)
    require 'openssl'
    require 'base64'
    require 'net/http'
    require 'json'
    require 'cgi'
    require 'time'
    require 'httpclient'
    @connection_string = connection_string
    @hub_name = hub_name
    @expiry_interval = expiry
    @proxy_addr = proxy_addr
    @proxy_port = proxy_port
    @open_timeout = open_timeout
    @read_timeout = read_timeout

    if @connection_string.count(';') != 2
      raise "Connection String format is not correct"
    end

    @connection_string.split(';').each do |part|
      if ( part.index('Endpoint') == 0 )
        @endpoint = 'https' + part[11..-1]
      elsif ( part.index('SharedAccessKeyName') == 0 )
        @sas_key_name = part[20..-1]
      elsif ( part.index('SharedAccessKey') == 0 )
        @sas_key_value = part[16..-1]
      end
    end
    @uri = URI.parse("#{@endpoint}#{@hub_name}/messages")

    if (proxy_addr.to_s.empty?)
      @client = HTTPClient.new
    else
      proxy_url = "#{proxy_addr}:#{proxy_port}"
      @client = HTTPClient.new(proxy)
    end
  end

  def generate_sas_token(uri)
    target_uri = CGI.escape(uri.downcase).downcase
    expiry = Time.now.to_i + @expiry_interval
    to_sign = "#{target_uri}\n#{expiry}";
    signature = CGI.escape(Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), @sas_key_value, to_sign)).strip())

    token = "SharedAccessSignature sr=#{target_uri}&sig=#{signature}&se=#{expiry}&skn=#{@sas_key_name}"
    return token
  end

  private :generate_sas_token

  def send(payload)
    send_w_properties(payload, nil)
  end

  def send_w_properties(payload, properties)
    token = generate_sas_token(@uri.to_s)
    headers = {
      'Content-Type' => 'application/atom+xml;type=entry;charset=utf-8',
      'Authorization' => token
    }
    if not properties.nil?
      headers = headers.merge(properties)
    end
    body = payload.to_json
    res = @client.post(@uri.to_s, body, headers)
    rescue HTTPClient::TimeoutError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ETIMEDOUT, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
  end
end
