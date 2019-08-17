# frozen_string_literal: true

module Arlo
  class Basestation

    attr_reader :basestation, :client

    def initialize(basestation, client)
      @basestation = basestation
      @client = client
    end

    def system_mode(mode = :arm)
      active = case mode
      when :arm      then 'mode0'
      when :disarm   then 'mode1'
      when :schedule then 'mode2'
      when :geofence then 'mode3'
      end

      client.notify(basestation, action: 'set', resource: 'modes', publishResponse: true, properties: { active: active })
    end

  end
end