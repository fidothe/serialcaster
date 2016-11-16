module Serialcaster
  class EpisodeDays
    DAYS = {
      0 => :sunday,
      1 => :monday,
      2 => :tuesday,
      3 => :wednesday,
      4 => :thursday,
      5 => :friday,
      6 => :saturday
    }.freeze

    attr_reader :days

    def initialize(*days)
      @days = Hash[days.map { |day| [day, true] }]
    end

    def available?(input_time)
      !!days[DAYS[input_time.wday]]
    end

    def ==(other)
      other.days == days
    end
  end
end
