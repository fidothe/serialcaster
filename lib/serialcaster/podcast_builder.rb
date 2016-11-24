require 'serialcaster/feed_builder'
require 'serialcaster/podcast'
require 'serialcaster/podcast_summary'

module Serialcaster
  class PodcastBuilder
    attr_reader :prefix, :fetcher, :creator

    def initialize(attrs)
      @prefix = attrs.fetch(:prefix)
      @fetcher = attrs.fetch(:fetcher)
      @creator = attrs.fetch(:creator)
    end

    def podcast(url, time)
      programme = programme(time)
      Podcast.new({
        prefix: prefix,
        programme: programme,
        feed_builder: feed_builder(url, programme)
      })
    end

    def podcast_summary
      PodcastSummary.new({
        prefix: prefix,
        programme: programme_summary
      })
    end

    private

    def programme_summary
      creator.programme_summary
    end

    def programme(time)
      creator.programme(time)
    end

    def file_url_generator
      fetcher.file_url_generator
    end

    def feed_builder(url, programme)
      FeedBuilder.new({
        url: url, programme: programme,
        file_url_generator: file_url_generator
      })
    end
  end
end
