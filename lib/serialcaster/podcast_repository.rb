require 'serialcaster/fetcher'
require 'serialcaster/creator'
require 'serialcaster/podcast_builder'
require 'forwardable'

module Serialcaster
  class PodcastRepository
    class << self
      extend Forwardable

      def_delegators :instance, :find_podcast, :find_podcast_summary, :podcast_summaries

      private

      def instance
        @instance ||= new(ENV['SERIALCASTER_BUCKET'])
      end
    end

    attr_reader :bucket_name

    def initialize(bucket_name)
      @bucket_name = bucket_name
    end

    def all_prefixes
      @all_prefixes ||= Fetcher.list(bucket_name)
    end

    def exists?(prefix)
      all.has_key?(prefix)
    end

    def find(prefix)
      return unless exists?(prefix)
      all[prefix]
    end

    def find_podcast(prefix, url, time)
      find(prefix).podcast(url, time)
    end

    def find_podcast_summary(prefix)
      find(prefix).podcast_summary
    end

    def podcast_summaries
      all.map { |prefix, builder| builder.podcast_summary }
    end

    private

    def all
      @all ||= Hash[all_prefixes.map { |prefix| [prefix, create(prefix)] }]
    end

    def create(prefix)
      fetcher = fetcher(prefix)
      PodcastBuilder.new({
        prefix: prefix, fetcher: fetcher, creator: creator(fetcher)
      })
    end

    def fetcher(prefix)
      Fetcher.new(bucket: bucket_name, prefix: prefix)
    end

    def creator(fetcher)
      Creator.new(fetcher.metadata_io, fetcher.file_list)
    end
  end
end
