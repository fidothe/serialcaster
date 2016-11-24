require 'serialcaster/podcast_summary'

module Serialcaster
  RSpec.describe PodcastSummary do
    let(:prefix) { 'journey-into-space' }
    let(:programme) { double }

    subject {
      PodcastSummary.new({
        prefix: prefix, programme: programme,
      })
    }

    it "returns its prefix" do
      expect(subject.prefix).to eq(prefix)
    end

    it "returns its programme" do
      expect(subject.programme).to be(programme)
    end
  end
end
