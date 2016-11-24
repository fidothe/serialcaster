require 'serialcaster/fetcher'
require 'serialcaster/creator'
require 'serialcaster/podcast_builder'

module Serialcaster
  RSpec.describe PodcastBuilder do
    let(:file_url_generator) { double }
    let(:fetcher) {
      instance_double(Fetcher, file_url_generator: file_url_generator)
    }
    let(:creator) { instance_double(Creator) }
    let(:prefix) { 'programme' }

    subject {
      PodcastBuilder.new({
        prefix: prefix, fetcher: fetcher, creator: creator
      })
    }

    context "building a Podcast" do
      let(:time) { double }
      let(:programme) { double }
      let(:feed_builder) { double }
      let(:url) { 'http://a.url/' }
      let(:podcast) { subject.podcast(url, time) }

      before do
        allow(creator).to receive(:programme).with(time) { programme }
        allow(FeedBuilder).to receive(:new).with({
          url: url, programme: programme,
          file_url_generator: file_url_generator
        }) { feed_builder }
      end

      it "has the right prefix" do
        expect(podcast.prefix).to eq(prefix)
      end

      it "has a programme" do
        expect(podcast.programme).to be(programme)
      end

      it "has a built feed" do
        expect(podcast.feed_builder).to be(feed_builder)
      end
    end

    context "building a PodcastSummary" do
      let(:programme_summary) { double }

      before do
        allow(creator).to receive(:programme_summary) { programme_summary }
      end

      it "has the right prefix" do
        expect(subject.podcast_summary.prefix).to eq(prefix)
      end

      it "has a programme" do
        expect(subject.podcast_summary.programme).to be(programme_summary)
      end
    end
  end
end
