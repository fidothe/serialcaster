require 'serialcaster/episode_days'

module Serialcaster
  RSpec.describe EpisodeDays do
    let(:friday) { Date.new(2016, 11, 11) }
    let(:monday) { Date.new(2016, 11, 14) }
    let(:wednesday) { Date.new(2016, 11, 16) }

    subject { EpisodeDays.new(:wednesday, :friday) }

    it "thinks a Friday is available" do
      expect(subject.available?(friday)).to be true
    end

    it "thinks a Monday is not available" do
      expect(subject.available?(monday)).to be false
    end

    it "thinks a wednesday is available" do
      expect(subject.available?(wednesday)).to be true
    end

    context "equality" do
      it "compares equal to an instance with the same days" do
        expect(subject).to eq(EpisodeDays.new(:friday, :wednesday))
      end

      it "compares non-equal to an instance with different days" do
        expect(subject).not_to eq(EpisodeDays.new(:friday, :monday))
      end

      it "doesn't care about the order days were passed in" do
        expect(EpisodeDays.new(:monday, :friday)).to eq(EpisodeDays.new(:friday, :monday))
      end
    end
  end
end
