require 'serialcaster/schedule'
require 'serialcaster/episode_time'
require 'serialcaster/episode_days'

module Serialcaster
  RSpec.describe Schedule do
    let(:friday_start) { Date.new(2016, 11, 18) }
    let(:time) { EpisodeTime.new('17:00') }
    let(:days) { EpisodeDays.new(:monday, :wednesday, :friday) }
    let(:episodes_attrs) { [
      {title: 'Operation Luna', number: 1, file: 'e1.m4a', content_length: 42},
      {title: 'Operation Luna', number: 2, file: 'e2.m4a', content_length: 42},
      {title: 'Operation Luna', number: 3, file: 'e3.m4a', content_length: 42},
      {title: 'Operation Luna', number: 4, file: 'e4.m4a', content_length: 42}
    ] }

    subject {
      Schedule.new({
        start: friday_start, time: time, days: days, episodes: episodes_attrs
      })
    }

    context "available episodes" do
      it "should have released no episodes before the start date" do
        expect(subject.episodes_at(DateTime.new(2016, 11, 17, 18))).to eq([])
      end

      it "should have released four episodes by the end of the next friday after the start" do
        expect(subject.episodes_at(DateTime.new(2016, 11, 25, 18)).count).to eq(4)
      end

      it "should have released two episodes by the tuesday after the start" do
        expect(subject.episodes_at(DateTime.new(2016, 11, 22, 18)).count).to eq(2)
      end

      context "making epsiodes available at the right time" do
        it "allows it if it's late enough" do
          time = friday_start.to_time + (60*60*18)
          expect(subject.episodes_at(time).count).to eq(1)
        end

        it "doesn't if it's too early" do
          time = friday_start.to_time + (60*60*16)
          expect(subject.episodes_at(time)).to eq([])
        end
      end
    end


    context "equality" do
      it "compares equal if its start, time, and days are all equal" do
        expect(subject).to eq(Schedule.new({
          start: friday_start, time: time, days: days, episodes: episodes_attrs
        }))
      end

      it "compares non-equal if one is different" do
        expect(subject).not_to eq(Schedule.new({
          start: friday_start, time: time, days: EpisodeDays.new(:friday), episodes: episodes_attrs
        }))
      end
    end
  end
end
