# Fluent::Plugin::Azureeventhubs

Azure Event Hubs buffered output plugin for Fluentd.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-azureeventhubs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-azureeventhubs

## Configuration

```
<match pattern>
  type azureeventhubs_buffered

  connection_string <Paste SAS connection string from Azure Management Potal>
  hub_name          <Name of Event Hubs>
  include_tag       (true|false) # true: Include tag into record [Optional: default => false]
  include_time      (true|false) # true: Include time into record [Optional: default => false]
  tag_time_name     record_time  # record tag for time when include_time sets true. [Optional: default => 'time']
  type              (https|amqps) # Connection type. [Optional: default => https]. Note that amqps is not implementated.
  expiry_interval   <Integer number> # Signature expiration time interval in seconds. [Optional: default => 3600 (60min)]
</match>
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fluent-plugin-azureeventhubs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
