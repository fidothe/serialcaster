module Serialcaster
  class Programme
    attr_reader :title, :description, :schedule, :episodes

    def initialize(attrs)
      @title = attrs.fetch(:title)
      @description = attrs.fetch(:description)
      @schedule = attrs.fetch(:schedule)
      @episodes = attrs.fetch(:episodes)
    end

    def ==(other)
      [:title, :description, :schedule, :episodes].all? { |meth|
        self.public_send(meth) == other.public_send(meth)
      }
    end
  end
end
