require 'serialcaster/episode'

module Serialcaster
  class Schedule
    attr_reader :start, :time, :days, :episodes

    def initialize(attrs)
      @start = attrs.fetch(:start)
      @time = attrs.fetch(:time)
      @days = attrs.fetch(:days)
      @episodes = attrs.fetch(:episodes)
    end

    def episodes_at(request_time)
      available_episode_times(request_time.to_time).zip(episodes).map { |time, attrs|
        Episode.new(attrs.merge(time: time))
      }
    end

    def ==(other)
      other.start == start && other.time == time && other.days == days
    end

    private

    def already_available_times(date)
      return [] if date <= start
      (start..date).select { |date|
        days.available?(date)
      }.map { |date|
        time.available_time(date)
      }
    end

    def available_episode_times(request_time)
      already_available_times(previous_day(request_time)) + new_episode_now(request_time)
    end

    def previous_day(request_time)
      request_time.to_date - 1
    end

    def new_episode_now(request_time)
      if days.available?(request_time) && time.available?(request_time)
        return [time.available_time(request_time)]
      end
      []
    end
  end
end
