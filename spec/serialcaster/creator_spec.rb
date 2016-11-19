require 'serialcaster/creator'
require 'stringio'
require 'json'

module Serialcaster
  RSpec.describe Creator do
    let(:input) { {
      programme: 'Journey Into Space',
      description: 'Classic BBC radio drama',
      episode_file_patterns: [
        '(?<title>Journey Into Space - Operation Luna) - Episode (?<episode>[0-9]+)',
        'Journey Into Space - (?<title>The Red Planet) - Episode (?<episode>[0-9]+)'
      ],
      schedule: {
        starting_from: '2016-11-18',
        days: ['sunday', 'wednesday'],
        time: '17:00'
      }
    } }
    let(:io) { StringIO.new(JSON.generate(input)) }
    let(:file_list) { [
      ['Journey Into Space - Operation Luna - Episode 1.m4a', 42],
      ['Journey Into Space - The Red Planet - Episode 2.m4a', 42],
      ['Journey Into Space - Operation Luna - Episode 2.m4a', 42],
      ['Journey Into Space - The Red Planet - Episode 1.m4a', 42],
      ['Journey Into Space - Operation Luna - Episode 10.m4a', 42],
      ['Random spacejunk Episode 1.m4a', 42],
      ['Assorted.mp3', 42]
    ] }

    subject { Creator.new(io, file_list) }

    it "generates a sensible schedule" do
      time = EpisodeTime.new('17:00')
      days = EpisodeDays.new(:sunday, :wednesday)
      schedule = Schedule.new({
        start: Date.new(2016, 11, 18), time: time, days: days, episodes: subject.episodes_attrs
      })

      expect(subject.schedule).to eq(schedule)
    end

    it "generates the correct episode list" do
      expect(subject.episodes_attrs).to eq([
        {title: 'Journey Into Space - Operation Luna', number: 1,
         file: 'Journey Into Space - Operation Luna - Episode 1.m4a',
         content_length: 42},
        {title: 'Journey Into Space - Operation Luna', number: 2,
         file: 'Journey Into Space - Operation Luna - Episode 2.m4a',
         content_length: 42},
        {title: 'Journey Into Space - Operation Luna', number: 10,
         file: 'Journey Into Space - Operation Luna - Episode 10.m4a',
         content_length: 42},
        {title: 'The Red Planet', number: 1,
         file: 'Journey Into Space - The Red Planet - Episode 1.m4a',
         content_length: 42},
        {title: 'The Red Planet', number: 2,
         file: 'Journey Into Space - The Red Planet - Episode 2.m4a',
         content_length: 42},
      ])
    end

    it "generates a programme correctly" do
      schedule = instance_double(Schedule)
      allow(subject).to receive(:schedule) { schedule }
      episodes = double
      time = double(Time)

      expect(schedule).to receive(:episodes_at).with(time) { episodes }

      programme = Programme.new({
        title: 'Journey Into Space',
        description: 'Classic BBC radio drama',
        episodes: episodes
      })

      expect(subject.programme(time)).to eq(programme)
    end

    it "generates a programme summary correctly" do
      summary = ProgrammeSummary.new({
        title: 'Journey Into Space',
        description: 'Classic BBC radio drama',
      })

      expect(subject.programme_summary).to eq(summary)
    end
  end
end
