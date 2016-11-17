module Serialcaster
  class EpisodeTime
    TIME = /\A([0-9]{2}):([0-9]{2})\Z/

    attr_reader :hour, :minute

    def initialize(time)
      @hour, @minute = TIME.match(time).captures
    end

    def available?(input_time)
      input_time >= available_time(input_time)
    end

    def available_time(input_time)
      y, m, d = input_time.year, input_time.mon, input_time.day
      Time.utc(y, m, d, hour, minute)
    end

    def ==(other)
      other.hour == hour && other.minute == minute
    end
  end
end
