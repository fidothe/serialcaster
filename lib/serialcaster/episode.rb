module Serialcaster
  class Episode
    attr_reader :title, :number, :file

    def initialize(attrs)
      @title = attrs.fetch(:title)
      @number = attrs.fetch(:number)
      @file = attrs.fetch(:file)
    end

    def ==(other)
      other.title == title && other.number == number && other.file == file
    end
  end
end
