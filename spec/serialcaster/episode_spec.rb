require 'serialcaster/episode'

module Serialcaster
  RSpec.describe Episode do
    let(:attrs) { {title: "title", number: 1, file: "file.m4a", time: Time.utc(2016, 1, 1)} }
    subject {
      Episode.new(attrs)
    }

    it "has a title" do
      expect(subject.title).to eq("title")
    end

    it "has a number" do
      expect(subject.number).to eq(1)
    end

    it "has a file" do
      expect(subject.file).to eq("file.m4a")
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
  end
end
