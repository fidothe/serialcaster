require 'serialcaster/episode_time'

module Serialcaster
  RSpec.describe EpisodeTime do
    subject { EpisodeTime.new("17:00") }

    context "checking a given DateTime against its time" do
      it "reports that a Time after its time is later" do
        t = Time.new(2016, 11, 12, 18)

        expect(subject.available?(t)).to be(true)
      end

      it "reports that a Time before its time is earlier" do
        t = Time.new(2016, 11, 13, 16)

        expect(subject.available?(t)).to be(false)
      end
    end

    it "reports that what the availability time on a given date it" do
      expected_time = Time.utc(2016, 1, 1, 17)
      actual_time = subject.available_time(Date.new(2016, 1, 1))
      expect(actual_time).to eq(expected_time)
    end

    context "equality" do
      it "compares equal with another instance with the same time" do
        expect(subject).to eq(EpisodeTime.new('17:00'))
      end

      it "compares non-equal with an instance with another time" do
        expect(subject).not_to eq(EpisodeTime.new('16:00'))
      end
    end
  end
end
