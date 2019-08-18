# frozen_string_literal: true

require 'awesome_print'
require 'down'
require 'ld-eventsource'
require 'lhc'
require 'json'
require 'terminal-table'

LHC.configure do |c|
  c.interceptors = [LHC::Auth]

  c.endpoint(:device_capabilities, 'https://my.arlo.com/resources/capabilities/{model}/{model}_{interface_version}.json')
  c.endpoint(:devices, 'https://my.arlo.com/hmsweb/users/devices')
  c.endpoint(:friends, 'https://my.arlo.com/hmsweb/users/friends')
  c.endpoint(:library, 'https://my.arlo.com/hmsweb/users/library')
  c.endpoint(:library_metadata, 'https://my.arlo.com/hmsweb/users/library/metadata')
  c.endpoint(:login, 'https://my.arlo.com/hmsweb/login/v2')
  c.endpoint(:notify, 'https://my.arlo.com/hmsweb/users/devices/notify/{to}')
  c.endpoint(:password, 'https://my.arlo.com/hmsweb/users/changePassword')
  c.endpoint(:profile, 'https://my.arlo.com/hmsweb/users/profile')
end

module Arlo
  # Primary client to access the Arlo servers
  class Client

    attr_reader :email, :password, :token
    attr_reader :account_status, :authenticated, :created, :logged_in, :serial_number, :user_id
    attr_reader :valid_email

    def login(email:, password:)
      @email = email

      response = LHC.post(:login, body: { email: email, password: password })
      # puts 'LOGIN'
      # ap response.data.data

      data = response.data.data

      if response.data.success
        @account_status = data.accountStatus
        @authenticated  = data.authenticated
        @created        = data.dateCreated
        @serial_number  = data.serialNumber
        @token          = data.token
        @user_id        = data.userId
        @valid_email    = data.validEmail

        rows = [
          ['User ID', user_id],
          ['Email', email],
          ['Valid Email', valid_email],
          ['Token', 'xxxxxxxxxxxxxx'],
          ['Authenticated', authenticated],
          ['Created', created]
        ]
        table = Terminal::Table.new title: 'Login', headings: ['Variable', 'Value'], rows: rows
        puts table
        puts

        @logged_in      = true
      else
        @logged_in = false
      end

      response
    end

    def connectivity(d)
      if d.connectivity
        "#{d.connectivity.type} / #{d.connectivity.connected ? 'connected' : 'disconnected'}"
      end
    end
    
    def device_capabilities(device)
      response = LHC.get(:device_capabilities, params: { model: device.modelId.downcase, interface_version: device.interfaceVersion })
    end

    def devices
      response = LHC.get(:devices, headers: default_headers)
      # puts 'DEVICES'
      # ap response.data.as_json

      rows = response.data.data.sort_by(&:deviceType).map { |d| [d.deviceId, d.parentId, d.uniqueId, d.deviceType, d.modelId, d.properties&.hwVersion, d.deviceName, d.state, connectivity(d) ] }
      table = Terminal::Table.new title: 'Devices', headings: ['ID', 'Parent ID', 'Unique ID', 'Type', 'Model', 'HW', 'Name', 'State', 'Connectivity'], rows: rows
      puts table
      puts
      
      if response.data.success
        response.data.data
      else
        []
      end
    end

    def download(from, to)
      Down.download(from, destination: to)
    end

    def default_headers
      {
        'DNT': '1',
        'schemaVersion': '1',
        'Host': 'my.arlo.com',
        'Referer': 'https://my.arlo.com/',
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 11_1_2 like Mac OS X) AppleWebKit/604.3.5 (KHTML, like Gecko) Mobile/15B202 NETGEAR/v1 (iOS Vuezone)',
        'Authorization': token
      }
    end

    def notify(basestation, body = {})
      body[:transId] = transaction_id
      body[:from] = "#{user_id}_web"
      body[:to] = basestation.deviceId

      post(:notify, params: { to: body[:to] }, body: body, headers: { 'xCloudId': basestation.xCloudId })
    end

    def get(url, params: {}, headers: {})
      LHC.get(url, params: params, headers: default_headers.merge(headers))
    end

    def post(url, params: {}, body: {}, headers: {})
      puts "POST - URL: #{url}, Params: #{params}, Body: #{body}"
      response = LHC.post(url, params: params, body: body, headers: default_headers.merge(headers))
      puts response.body
      if response.data.success
        response.data.data
      else
        raise StandardError, "POST Error: #{response.data.data.message}"
      end
    end

    def put(url, params: {}, body: {}, headers: {})
      puts "PUT - URL: #{url}, Params: #{params}, Body: #{body}"
      response = LHC.put(url, params: params, body: body, headers: default_headers.merge(headers))
      puts response.body
      if response.data.success
        response.data.data
      else
        raise StandardError, "PUT Error: #{response.data.data.message}"
      end
    end

    def subscribe(basestation)
      SSE::Client.new("https://my.arlo.com/hmsweb/client/subscribe?token=#{token}", headers: default_headers) do |client|
        client.on_event do |event|
          puts "Event: #{event.type}, #{event.data}"
        end

        client.on_error do |error|
          puts "Error: #{error}"
        end
      end
    end

    def transaction_id(prefix = 'web')
      "#{prefix}!#{(rand() * 2**32).round.to_s(16)}!#{Time.now.utc.to_i}"
    end

    def update_password(current_password, new_password)
      put(:password, body: { currentPassword: current_password, newPassword: new_password })
    end

    def update_profile(first_name, last_name)
      put(:profile, body: { firstName: first_name, lastName: last_name })
    end

  end
end
