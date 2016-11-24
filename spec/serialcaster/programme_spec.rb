require 'serialcaster/programme'
require 'serialcaster/episode'

module Serialcaster
  RSpec.describe Programme do
    let(:ep1) {
      Episode.new({
        title: "e1", file: "1.m4a", number: 1,
        content_length: 42, time: Time.utc(2016,11,1)
      })
    }
    let(:ep2) {
      Episode.new({
        title: "e2", file: "2.m4a", number: 2,
        content_length: 42, time: Time.utc(2016,11,2)
      })
    }
    let(:episodes) { [ep1, ep2] }
    let(:attrs) { {
      title: 'Journey Into Space',
      description: 'Classic BBC radio drama',
      episodes: episodes
    } }
    subject {
      Programme.new(attrs)
    }

    it "has a title" do
      expect(subject.title).to eq('Journey Into Space')
    end

    it "has a description" do
      expect(subject.description).to eq('Classic BBC radio drama')
    end

    it "has an episode list" do
      expect(subject.episodes).to eq(episodes)
    end

    it "allows episodes to be fetched via number" do
      expect(subject.episode("2")).to be(ep2)
    end

    context "generating an ETag" do
      it "generates the same value for different Programmes that compare equal" do
        expect(subject.etag).to eq(Programme.new(attrs).etag)
      end

      it "changes if title/description change" do
        expect(subject.etag).not_to eq(Programme.new(attrs.merge({
          title: "Journey Into Brandenburg"
        })).etag)
      end

      it "changes if episodes change" do
        expect(subject.etag).not_to eq(Programme.new(attrs.merge({
          episodes: [ep1, ep2, ep1]
        })).etag)
      end
    end

    context "equality" do
      it "compares equal when all attributes match" do
        expect(subject).to eq(Programme.new(attrs))
      end

      it "compares non-equal when one attribute doesn't match" do
        expect(subject).not_to eq(Programme.new(attrs.merge(title: 'Boo')))
      end
    end
  end
end
