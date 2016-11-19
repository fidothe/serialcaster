require 'sinatra/base'
require 'uri'
require 'serialcaster/fetcher'
require 'serialcaster/podcast'

module Serialcaster
  class App < Sinatra::Base
    def self.podcast_prefixes
      Fetcher.list(ENV.fetch('SERIALCASTER_BUCKET'))
    end

    def self.podcasts
      @podcasts ||= Hash[podcast_prefixes.map { |prefix|
        fetcher = Fetcher.new({
          bucket: ENV.fetch('SERIALCASTER_BUCKET'),
          prefix: prefix
        })
        [prefix, Podcast.new(fetcher)]
      }]
    end

    def podcasts
      self.class.podcasts
    end

    set :views, File.expand_path('../../views', __dir__)

    set(:authed) { |_|
      condition {
        request['t'] == ENV.fetch('SERIALCASTER_SEKRIT_TOKEN')
      }
    }

    get '/', authed: true do
      summaries = podcasts.map { |prefix, podcast|
        [
          "/#{prefix}?t=#{ENV['SERIALCASTER_SEKRIT_TOKEN']}",
          podcast.programme_summary
        ]
      }

      erb :list, locals: {podcasts: summaries}
    end

    get '/:podcast.rss', authed: true do
      podcast = podcasts[params[:podcast]]
      not_found && return if podcast.nil?

      status 200
      content_type 'application/rss+xml'
      body podcast.feed_builder(request.url, Time.now.utc).to_s
    end

    get '/:podcast', authed: true do
      podcast = podcasts[params[:podcast]]
      not_found && return if podcast.nil?
      rss_path = "/#{params[:podcast]}.rss"
      rss_query = "t=#{ENV['SERIALCASTER_SEKRIT_TOKEN']}"
      rss_url = URI::Generic.build({
        scheme: request.scheme,
        host: request.host,
        path: rss_path,
        query: rss_query
      }).to_s


      erb :show, locals: {summary: podcast.programme_summary, rss_url: rss_url}
    end
  end
end
