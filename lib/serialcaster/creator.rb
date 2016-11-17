require 'serialcaster/schedule'
require 'serialcaster/episode_time'
require 'serialcaster/episode_days'
require 'serialcaster/programme'
require 'serialcaster/episode'
require 'json'
require 'date'

module Serialcaster
  class Creator
    attr_reader :file_list

    def initialize(metadata_io, file_list)
      @metadata_io = metadata_io
      @file_list = file_list
    end

    def metadata_json
      @metadata_json ||= JSON.load(@metadata_io)
    end

    def schedule
      @schedule ||= Schedule.new({
        start: Date.parse(schedule_metadata['starting_from']),
        time: episode_time,
        days: episode_days,
        episodes: episodes_attrs
      })
    end

    def episodes_attrs
      @episodes_attrs ||= extract_episode_attrs
    end

    def programme(request_time)
      @programme ||= Programme.new({
        title: metadata_json['programme'],
        description: metadata_json['description'],
        episodes: schedule.episodes_at(request_time)
      })
    end

    private

    def schedule_metadata
      metadata_json['schedule']
    end

    def episode_time
      @episode_time ||= EpisodeTime.new(schedule_metadata['time'])
    end

    def episode_days
      @episode_days ||= EpisodeDays.new(*schedule_metadata['days'].map(&:to_sym))
    end

    def episode_file_patterns
      @episode_file_patterns ||= begin
        metadata_json['episode_file_patterns'].map { |pattern|
          Regexp.compile(pattern)
        }
      end
    end

    def extract_episode_attrs
      file_list.map(&details_extractor).compact.sort(&details_sorter)
        .map { |season, episode_number, title, file, content_length|
          {
            title: title, number: episode_number,
            file: file, content_length: content_length
          }
        }
    end

    def details_extractor
      ->(file, content_length) {
        pattern, season = episode_file_patterns.each_with_index.find { |pattern, season|
          pattern.match(file)
        }
        return nil if pattern.nil?

        match = pattern.match(file)
        episode_number = match.names.include?('episode') ? Integer(match[:episode], 10) : "X"
        title = match.names.include?('title') ? match[:title] : file

        [season, episode_number, title, file, content_length]
      }
    end

    def details_sorter
      ->(a, b) {
        a_season, a_episode, a_title, _ = a
        b_season, b_episode, b_title, _ = b
        season = a_season <=> b_season
        return season unless season == 0
        episode = a_episode <=> b_episode
        return episode unless episode == 0
        a_title <=> b_title
      }
    end
  end
end
