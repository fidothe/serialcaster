require 'serialcaster/feed_builder'
require 'serialcaster/programme'
require 'serialcaster/episode'
require 'rss'

module Serialcaster
  RSpec.describe FeedBuilder do
    let(:episode) {
      Episode.new({
        title: "Episode 1",
        number: 1,
        file: "file.m4a",
        time: Time.utc(2016, 1, 1),
        content_length: 42
      })
    }
    let(:programme) {
      Programme.new({
        title: 'Journey Into Space',
        description: 'Classic BBC radio drama',
        episodes: [episode]
      })
    }
    let(:file_url_generator) {
      ->(file) { "https://#{file}" }
    }

    it "generates feed RSS without blowing up" do
      expect {
      }.not_to raise_error
    end

    context "the RSS feed" do
      let(:rss) {
        FeedBuilder.new({
          url: 'https://feed.rss',
          programme: programme,
          file_url_generator: file_url_generator
        }).to_s
      }
      let(:parsed_feed) { ::RSS::Parser.parse(rss) }

      context "an episode" do
        let(:parsed_episode) { parsed_feed.items.first }

        it "has the correct pub date/time" do
          expect(parsed_episode.date).to eq(episode.time)
        end
      end
    end
  end
end
