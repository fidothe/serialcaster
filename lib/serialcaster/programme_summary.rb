module Serialcaster
  class ProgrammeSummary
    attr_reader :title, :description

    def initialize(attrs)
      @title = attrs.fetch(:title)
      @description = attrs.fetch(:description)
    end

    def ==(other)
      [:title, :description].all? { |meth|
        self.public_send(meth) == other.public_send(meth)
      }
    end
  end
end
