require 'digest/sha1'

module Serialcaster
  class Episode
    attr_reader :title, :number, :file, :content_length, :time

    def initialize(attrs)
      @title = attrs.fetch(:title)
      @number = attrs.fetch(:number)
      @file = attrs.fetch(:file)
      @content_length = attrs.fetch(:content_length)
      @time = attrs.fetch(:time)
    end

    def ==(other)
      [:title, :number, :file, :content_length, :time].all? { |meth|
        self.public_send(meth) == other.public_send(meth)
      }
    end

    def rss_guid
      @rss_guid ||= begin
        digest = Digest::SHA1.new
        digest << file
        digest << content_length.to_s
        digest.hexdigest
      end
    end
  end
end
