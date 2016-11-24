require 'digest/sha1'

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

    def episode(number)
      episodes_by_number[number.to_s]
    end

    def etag
      @etag ||= begin
        digest = Digest::SHA1.new
        digest << title << description
        episodes.each do |episode|
          digest << episode.rss_guid
        end
        digest.hexdigest
      end
    end

    private

    def episodes_by_number
      @episodes_by_number ||= Hash[
        episodes.map { |e| [e.number.to_s, e] }
      ]
    end
  end
end
