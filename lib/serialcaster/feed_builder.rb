require 'rss'
require 'mime/types'

module Serialcaster
  class FeedBuilder
    attr_reader :url, :programme, :url_generator

    def initialize(attrs)
      @url = attrs.fetch(:url)
      @programme = attrs.fetch(:programme)
      @url_generator = attrs.fetch(:url_generator)
    end

    def feed
      rss = RSS::Maker.make("2.0") do |maker|
        maker.channel.language = "en"
        maker.channel.author = "Matt Patterson"
        maker.channel.updated = updated_time
        maker.channel.link = url
        maker.channel.title = programme.title
        maker.channel.description = programme.description
        programme.episodes.reverse.each do |episode|
          media_url = url_generator.call(episode.file)
          mime_type = MIME::Types.type_for(episode.file).first
          maker.items.new_item do |item|
            item.link = media_url
            item.title = episode.title
            item.guid.content = episode.rss_guid
            item.updated = Time.now.to_s
            item.enclosure.url = media_url
            item.enclosure.type = mime_type
            item.enclosure.length = episode.content_length
          end
        end
      end
    end

    def to_s
      feed.to_s
    end

    private

    def updated_time
      most_recent = programme.episodes.last
      most_recent.nil? ? Time.now.utc : most_recent.time
    end
  end
end
