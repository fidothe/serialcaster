module Serialcaster
  class Podcast
    attr_reader :prefix, :programme, :feed_builder

    def initialize(attrs)
      @prefix = attrs.fetch(:prefix)
      @programme = attrs.fetch(:programme)
      @feed_builder = attrs.fetch(:feed_builder)
    end
  end
end
