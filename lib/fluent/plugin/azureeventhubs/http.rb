
class AzureEventHubsHttpSender
  def initialize(connection_string, hub_name, expiry=3600,proxy_addr='',proxy_port=3128,open_timeout=60,read_timeout=60)
    require 'openssl'
    require 'base64'
    require 'net/http'
    require 'json'
    require 'cgi'
    require 'time'
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
    token = generate_sas_token(@uri.to_s)
    headers = {
      'Content-Type' => 'application/atom+xml;type=entry;charset=utf-8',
      'Authorization' => token
    }
    if (@proxy_addr.to_s.empty?)
    	https = Net::HTTP.new(@uri.host, @uri.port)
        https.open_timeout = @open_timeout
        https.read_timeout = @read_timeout
    else
    	https = Net::HTTP.new(@uri.host, @uri.port,@proxy_addr,@proxy_port)
        https.open_timeout = @open_timeout
        https.read_timeout = @read_timeout
    end
    https.use_ssl = true
    req = Net::HTTP::Post.new(@uri.request_uri, headers)
    req.body = payload.to_json
    res = https.request(req)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ETIMEDOUT, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
  end
end
