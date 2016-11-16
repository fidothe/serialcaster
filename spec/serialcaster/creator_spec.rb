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
      'Journey Into Space - Operation Luna - Episode 1.m4a',
      'Journey Into Space - The Red Planet - Episode 2.m4a',
      'Journey Into Space - Operation Luna - Episode 2.m4a',
      'Journey Into Space - The Red Planet - Episode 1.m4a',
      'Journey Into Space - Operation Luna - Episode 10.m4a',
      'Random spacejunk Episode 1.m4a',
      'Assorted.mp3'
    ] }

    subject { Creator.new(io, file_list) }

    it "generates a sensible schedule" do
      time = EpisodeTime.new('17:00')
      days = EpisodeDays.new(:sunday, :wednesday)
      schedule = Schedule.new({
        start: Date.new(2016, 11, 18), time: time, days: days
      })

      expect(subject.schedule).to eq(schedule)
    end

    it "generates the correct episode list" do
      expect(subject.episodes).to eq([
        Episode.new(title: 'Journey Into Space - Operation Luna', number: 1,
                    file: 'Journey Into Space - Operation Luna - Episode 1.m4a'),
        Episode.new(title: 'Journey Into Space - Operation Luna', number: 2,
                    file: 'Journey Into Space - Operation Luna - Episode 2.m4a'),
        Episode.new(title: 'Journey Into Space - Operation Luna', number: 10,
                    file: 'Journey Into Space - Operation Luna - Episode 10.m4a'),
        Episode.new(title: 'The Red Planet', number: 1,
                    file: 'Journey Into Space - The Red Planet - Episode 1.m4a'),
        Episode.new(title: 'The Red Planet', number: 2,
                    file: 'Journey Into Space - The Red Planet - Episode 2.m4a')
      ])
    end

    it "generates a programme correctly" do
      schedule = double
      episodes = double
      allow(subject).to receive(:schedule) { schedule }
      allow(subject).to receive(:episodes) { episodes }

      programme = Programme.new({
        title: 'Journey Into Space',
        description: 'Classic BBC radio drama',
        schedule: schedule,
        episodes: episodes
      })

      expect(subject.programme).to eq(programme)
    end
  end
end
