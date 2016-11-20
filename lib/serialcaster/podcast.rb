require 'serialcaster/creator'
require 'serialcaster/feed_builder'
require 'forwardable'

module Serialcaster
  class Podcast
    extend Forwardable

    attr_reader :fetcher

    def_delegators :creator, :programme_summary, :programme

    def initialize(fetcher)
      @fetcher = fetcher
    end

    def creator
      @creator ||= Creator.new(fetcher.metadata_io, fetcher.file_list)
    end

    def feed_builder(url, time)
      FeedBuilder.new({
        url: url, url_generator: fetcher.file_url_generator,
        programme: programme(time)
      })
    end
  end
end
