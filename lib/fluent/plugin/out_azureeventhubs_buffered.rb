#module Fluent

  class AzureEventHubsOutputBuffered < Fluent::BufferedOutput
    Fluent::Plugin.register_output('azureeventhubs_buffered', self)

    config_param :connection_string, :string
    config_param :hub_name, :string
    config_param :include_tag, :bool, :default => false
    config_param :include_time, :bool, :default => false
    config_param :tag_time_name, :string, :default => 'time'
    config_param :expiry_interval, :integer, :default => 3600 # 60min
    config_param :type, :string, :default => 'https' # https / amqps (Not Implemented) 
    config_param :proxy_addr, :string, :default => ''
    config_param :proxy_port, :integer,:default => 3128
    config_param :open_timeout, :integer,:default => 60
    config_param :read_timeout, :integer,:default => 60

    def configure(conf)
      super
      case @type
      when 'amqps'
        raise NotImplementedError
      else
        require_relative 'azureeventhubs/http'
        @sender = AzureEventHubsHttpSender.new(@connection_string, @hub_name, @expiry_interval,@proxy_addr,@proxy_port,@open_timeout,@read_timeout)
      end
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each { |tag, time, record|
        p record.to_s
        if @include_tag
          record['tag'] = tag
        end
        if @include_time
          record[@tag_time_name] = time
        end
        @sender.send(record)
      }
    end
  end
#end

