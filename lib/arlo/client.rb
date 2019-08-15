# frozen_string_literal: true

module Arlo
  # Primary client to access the Arlo servers
  class Client

    attr_reader :username, :password, :token

    def login(username:, password:)
      response = LHC.post('https://my.arlo.com/hmsweb/login/v2', { email: username, password: password })

      @token = response.body['token']
      puts token
      true
    end

    private

    def headers
      {
        'DNT': '1',
        'schemaVersion': '1',
        'Host': 'my.arlo.com',
        'Content-Type': 'application/json; charset=utf-8;',
        'Referer': 'https://my.arlo.com/',
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 11_1_2 like Mac OS X) AppleWebKit/604.3.5 (KHTML, like Gecko) Mobile/15B202 NETGEAR/v1 (iOS Vuezone)',
        'Authorization': body['token']
      }
    end

  end
end
