require 'serialcaster/podcast'
require 'serialcaster/fetcher'

module Serialcaster
  RSpec.describe Podcast do
    let(:metadata_io) { double }
    let(:file_list) { double }
    let(:url_generator) { double }
    let(:fetcher) {
      instance_double(Fetcher, {
        metadata_io: metadata_io, file_list: file_list, file_url_generator: url_generator
      })
    }

    subject { Podcast.new(fetcher) }

    it "returns its Fetcher" do
      expect(subject.fetcher).to be(fetcher)
    end

    it "correctly generates a Creator" do
      creator = instance_double(Creator)

      expect(Creator).to receive(:new).with(metadata_io, file_list) { creator }

      expect(subject.creator).to be(creator)
    end

    it "exposes the programme_summary" do
      programme_summary = instance_double(ProgrammeSummary)
      creator = instance_double(Creator, programme_summary: programme_summary)
      allow(subject).to receive(:creator) { creator }

      expect(subject.programme_summary).to be(programme_summary)
    end

    it "exposes the programme creator" do
      programme = instance_double(Programme)
      creator = instance_double(Creator)
      time = double
      allow(subject).to receive(:creator) { creator }

      expect(creator).to receive(:programme).with(time) { programme }

      expect(subject.programme(time)).to be(programme)
    end

    it "correctly generates a FeedBuilder" do
      feed_builder = instance_double(FeedBuilder)
      programme = instance_double(Programme)
      time = double
      url = 'https://a.url/'
      allow(subject).to receive(:programme).with(time) { programme }

      expect(FeedBuilder).to receive(:new).with({
        url: url, programme: programme, url_generator: url_generator
      }) { feed_builder }

      expect(subject.feed_builder(url, time)).to be(feed_builder)
    end
  end
end
