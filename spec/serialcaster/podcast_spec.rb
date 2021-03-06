require 'serialcaster/podcast'

module Serialcaster
  RSpec.describe Podcast do
    let(:prefix) { 'journey-into-space' }
    let(:programme) { double }
    let(:feed_builder) { double }

    subject {
      Podcast.new({
        prefix: prefix, programme: programme,
        feed_builder: feed_builder
      })
    }

    it "returns its prefix" do
      expect(subject.prefix).to eq(prefix)
    end

    it "returns its programme" do
      expect(subject.programme).to be(programme)
    end

    it "returns its feed_builder" do
      expect(subject.feed_builder).to be(feed_builder)
    end
  end
end
