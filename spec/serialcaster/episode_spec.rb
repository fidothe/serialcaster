require 'serialcaster/episode'

module Serialcaster
  RSpec.describe Episode do
    let(:attrs) { {
      title: "title", number: 1, file: "file.m4a", time: Time.utc(2016, 1, 1),
      content_length: 42
    } }

    subject { Episode.new(attrs) }

    it "has a title" do
      expect(subject.title).to eq("title")
    end

    it "has a number" do
      expect(subject.number).to eq(1)
    end

    it "has a file" do
      expect(subject.file).to eq("file.m4a")
    end

    it "has a content length" do
      expect(subject.content_length).to eq(42)
    end

    it "has a time" do
      expect(subject.time).to eq(Time.utc(2016, 1, 1))
    end

    context "equality" do
      it "compares equal when title, number, and file match" do
        expect(subject).to eq(Episode.new(attrs))
      end

      it "compares non-equal when one of title, number, and file doesn't match" do
        expect(subject).not_to eq(Episode.new(attrs.merge(number: 10)))
      end
    end

    context "generating a guid" do
      it "considers file and content_length" do
        other_episode_1 = Episode.new(attrs.merge(file: 'diff.mp4'))
        other_episode_2 = Episode.new(attrs.merge(content_length: 13))

        expect(subject.rss_guid).not_to eq(other_episode_1.rss_guid)
        expect(subject.rss_guid).not_to eq(other_episode_2.rss_guid)
      end

      it "ignores everything except file and content_length" do
        other_episode = Episode.new(attrs.merge({
          title: 'other', number: 2, time: Time.new(2014,1,1)
        }))

        expect(subject.rss_guid).to eq(other_episode.rss_guid)
      end
    end
  end
end
