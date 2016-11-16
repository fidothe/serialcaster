require 'serialcaster/schedule'
require 'serialcaster/episode_time'
require 'serialcaster/episode_days'

module Serialcaster
  RSpec.describe Schedule do
    let(:friday_start) { Date.new(2016, 11, 18) }
    let(:time) { EpisodeTime.new('17:00') }
    let(:days) { EpisodeDays.new(:monday, :wednesday, :friday) }

    subject {
      Schedule.new({
        start: friday_start, time: time, days: days
      })
    }

    context "already available episodes" do
      it "should have released no episodes before the start date" do
        expect(subject.already_available_episodes(Date.new(2016, 11, 17))).to eq(0)
      end

      it "should have released four episodes by the end of the next friday after the start" do
        expect(subject.already_available_episodes(Date.new(2016, 11, 25))).to eq(4)
      end

      it "should have released two episodes by the tuesday after the start" do
        expect(subject.already_available_episodes(Date.new(2016, 11, 22))).to eq(2)
      end
    end

    context "making a new episode available today" do
      it "allows it if it's late enough" do
        time = friday_start.to_time + (60*60*18)
        expect(subject.available_episodes(time)).to eq(1)
      end

      it "doesn't if it's too early" do
        time = friday_start.to_time + (60*60*16)
        expect(subject.available_episodes(time)).to eq(0)
      end
    end

    context "equality" do
      it "compares equal if its start, time, and days are all equal" do
        expect(subject).to eq(Schedule.new({
          start: friday_start, time: time, days: days
        }))
      end

      it "compares non-equal if one is different" do
        expect(subject).not_to eq(Schedule.new({
          start: friday_start, time: time, days: EpisodeDays.new(:friday)
        }))
      end
    end
  end
end
