# frozen_string_literal: true

module Arlo
  class Basestation

    attr_reader :basestation, :client

    def initialize(basestation, client)
      @basestation = basestation
      @client = client
    end

    def library(from = 4.weeks.ago, to = Time.current)
      client.post(:library, {}, { dateFrom: from.strftime('%Y%m%d'), dateTo: to.strftime('%Y%m%d') })
    end

    def download_library(to = 'arlo_videos')
      Dir.mkdir(to) unless File.exists?(to)
      library.data.each do |video|
        destination = "#{to}/#{video.name}.mp4"
        puts "Downloading #{video.name} to #{destination}..."
        client.download(video.presignedContentUrl, destination)
      end
    end

    def system_mode(mode = :arm)
      resource, active = case mode
      when :arm 
        ['modes', 'mode1']
      when :disarm
        ['modes', 'mode0']
      when :schedule
        ['schedule', true]
      end

      client.notify(basestation, action: 'set', resource: resource, publishResponse: true, properties: { active: active })
    end

  end
end