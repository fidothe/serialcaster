module Serialcaster
  class PodcastSummary
    attr_reader :prefix, :programme

    def initialize(attrs)
      @prefix = attrs.fetch(:prefix)
      @programme = attrs.fetch(:programme)
    end
  end
end
