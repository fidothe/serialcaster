require 'sinatra/base'
require 'uri'
require 'serialcaster/fetcher'
require 'serialcaster/podcast_repository'

module Serialcaster
  class App < Sinatra::Base
    def podcast_summaries
      PodcastRepository.podcast_summaries
    end

    def podcast
      @podcast ||= PodcastRepository.find_podcast(params[:podcast], request.url, Time.now.utc)
    end

    def podcast_summary
      @podcast_summary ||= PodcastRepository.find_podcast_summary(params[:podcast])
    end

    set :views, File.expand_path('../../views', __dir__)

    set(:authed) { |_|
      condition {
        request['t'] == ENV.fetch('SERIALCASTER_SEKRIT_TOKEN')
      }
    }

    get '/', authed: true do
      summaries = podcast_summaries.map { |podcast|
        [
          "/#{podcast.prefix}?t=#{ENV['SERIALCASTER_SEKRIT_TOKEN']}",
          podcast.programme
        ]
      }

      erb :list, locals: {podcasts: summaries}
    end

    get '/:podcast.rss', authed: true do
      not_found && return if podcast.nil?
      etag podcast.programme.etag, :weak
      last_modified podcast.programme.episodes.last.time
      expires 86400, :public

      status 200
      content_type 'application/rss+xml'
      body podcast.feed_builder.to_s
    end

    get '/:podcast', authed: true do
      not_found && return if podcast_summary.nil?
      rss_path = "/#{params[:podcast]}.rss"
      rss_query = "t=#{ENV['SERIALCASTER_SEKRIT_TOKEN']}"
      rss_url = URI::Generic.build({
        scheme: request.scheme,
        host: request.host,
        path: rss_path,
        query: rss_query
      }).to_s


      erb :show, locals: {summary: podcast_summary.programme, rss_url: rss_url}
    end
  end
end
