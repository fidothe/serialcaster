module Serialcaster
  class Schedule
    attr_reader :start, :time, :days

    def initialize(opts)
      @start = opts.fetch(:start)
      @time = opts.fetch(:time)
      @days = opts.fetch(:days)
    end

    def already_available_episodes(date)
      return 0 if date <= start
      (start..date).select { |date|
        days.available?(date)
      }.count
    end

    def available_episodes(request_time)
      already_available_episodes(previous_day(request_time)) + new_episode_now(request_time)
    end

    def ==(other)
      other.start == start && other.time == time && other.days == days
    end

    private

    def previous_day(request_time)
      request_time.to_date - 1
    end

    def new_episode_now(request_time)
      if days.available?(request_time) && time.available?(request_time)
        return 1
      end
      0
    end
  end
end
