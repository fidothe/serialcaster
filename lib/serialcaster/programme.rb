module Serialcaster
  class Programme
    attr_reader :title, :description, :episodes

    def initialize(attrs)
      @title = attrs.fetch(:title)
      @description = attrs.fetch(:description)
      @episodes = attrs.fetch(:episodes)
    end

    def ==(other)
      [:title, :description, :episodes].all? { |meth|
        self.public_send(meth) == other.public_send(meth)
      }
    end
  end
end
