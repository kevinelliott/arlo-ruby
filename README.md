# Arlo

A client library written in Ruby to interact with the NetGear Arlo camera system.

While this is functional, it is still incomplete. Contributions of any kind at this time are welcome and encouraged!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arlo-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arlo-ruby

## Usage

### Initialize the client

```ruby
client = Arlo::Client.new
```

### Login

```ruby
response = client.login(email: 'YOUR EMAIL', password: 'YOUR PASSWORD')
```

### Get Devices

Retrieves all of the devices associated with your account.

```ruby
devices = client.devices
```

```
+---------------+----------------------+
|                Login                 |
+---------------+----------------------+
| Variable      | Value                |
+---------------+----------------------+
| User ID       | NZ69AUK-336-51372586 |
| Email         | kevin+dev@phunc.com  |
| Valid Email   | true                 |
| Token         | xxxxxxxxxxxxxx       |
| Authenticated | 1566062204           |
| Created       | 1565912809854        |
+---------------+----------------------+

+---------------+---------------+----------------------------------+-------------+---------------+-----------+---------------------+-------------+----------------------+
|                                                                                Devices                                                                                |
+---------------+---------------+----------------------------------+-------------+---------------+-----------+---------------------+-------------+----------------------+
| ID            | Parent ID     | Unique ID                        | Type        | Model         | HW        | Name                | State       | Connectivity         |
+---------------+---------------+----------------------------------+-------------+---------------+-----------+---------------------+-------------+----------------------+
| 4R036C71A22F2 |               | Z92W-336-6644878_4R036C71A22F2   | basestation | VMB4000       | VMB4000r3 | Beatty Base Station | provisioned | ethernet / connected |
| 4XH16C71A8A5C | 4R036C71A22F2 | Z92W-336-6644878_4XH16C71A8A5C   | camera      | VMC4030       | H8        | Office              | provisioned |                      |
| 4XH16C7EAA32C | 4R036C71A22F2 | Z92W-336-6644878_4XH16C7EAA32C   | camera      | VMC4030       | H8        | Family Room         | provisioned |                      |
| 4R036C71A22F2 | 4R036C71A22F2 | Z92W-336-6644878_4R036C71A22F2#1 | siren       | VMB4000-siren |           | Beatty Base Station | provisioned |                      |
+---------------+---------------+----------------------------------+-------------+---------------+-----------+---------------------+-------------+----------------------+
```

### Setup a Basestation Object

This allows you to operate directly on a basestation.

```ruby
basestation = Arlo::Basestation.new(devices.detect { |device| device.deviceType == 'basestation' }, client)
```

### Set Mode

```ruby
basestation.system_mode(:disarm)
basestation.system_mode(:arm)
```

Valid modes: `:disarm`, `:arm`

### Get Video Library

Returns an array of OpenStruct that contain details about the captured videos associated with your basestation.

```ruby
videos = basestation.library(2.weeks.ago, Time.current)
```

### Download Video Library

This is useful in order to backup your captured videos to local storage, or perhaps a NAS on your network.

```ruby
basestation.download_library('arlo_videos')
Downloading 1566061318696 to arlo_videos/1566061318696.mp4...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kevinelliott/arlo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

