require 'serialcaster/feed_builder'
require 'serialcaster/programme'
require 'serialcaster/episode'

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
        FeedBuilder.new({
          url: 'https://feed.rss',
          programme: programme,
          file_url_generator: file_url_generator
        }).to_s
      }.not_to raise_error
    end
  end
end
