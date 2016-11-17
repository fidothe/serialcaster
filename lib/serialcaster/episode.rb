module Serialcaster
  class Episode
    attr_reader :title, :number, :file, :time

    def initialize(attrs)
      @title = attrs.fetch(:title)
      @number = attrs.fetch(:number)
      @file = attrs.fetch(:file)
      @time = attrs.fetch(:time)
    end

    def ==(other)
      [:title, :number, :file, :time].all? { |meth|
        self.public_send(meth) == other.public_send(meth)
      }
    end
  end
end
