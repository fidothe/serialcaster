ENV['RACK_ENV'] = 'test'
ENV['SERIALCASTER_SEKRIT_TOKEN'] = 'sekrit'
ENV['SERIALCASTER_BUCKET'] = 'mp-serialcaster-test'

require 'serialcaster/app'  # <-- your sinatra app
require 'rack/test'

module Serialcaster
  describe App do
    include Rack::Test::Methods

    def app
      subject
    end

    let(:jis_podcast_summary) {
      instance_double(PodcastSummary, {
        prefix: 'journey-into-space', programme: jis_summary
      })
    }
    let(:jis_summary) {
      ProgrammeSummary.new({
        title: "Journey into space",
        description: "Classic"
      })
    }
    let(:jis_fetcher) {
      instance_double(Fetcher)
    }
    let(:episode) {
      Episode.new({
        title: 'ep', number: 1, file: 'f.mp3',
        content_length: 42, time: Time.utc(2016, 11, 1)
      })
    }
    let(:programme) {
      Programme.new(title: 'Drama', description: 'Much', episodes: [episode])
    }
    let(:jis_podcast) {
      instance_double(Podcast, programme: programme)
    }

    describe "/" do
      before do
        allow(PodcastRepository).to receive(:podcast_summaries) {
          [jis_podcast_summary]
        }
      end

      it "lets you through with the sekrit token" do
        get '/?t=sekrit'

        expect(last_response).to be_ok
      end

      it "404s if you don't use the token" do
        get '/'

        expect(last_response).to be_not_found
      end

      it "lists available podcasts" do
        get '/?t=sekrit'

        expect(last_response.body).to match(/Journey into space/)
      end
    end

    describe "/:podcast" do
      context "successfully fetching the page" do
        before do
          allow(PodcastRepository).to receive(:find_podcast_summary).with('journey-into-space') {
            jis_podcast_summary
          }

          get '/journey-into-space?t=sekrit'
        end

        it "lets you through with the sekrit token" do
          expect(last_response).to be_ok
        end


        it "shows a standard HTML link to the podcast RSS" do
          expected_link = '<a href="http://example.org/journey-into-space.rss?t=sekrit">Podcast RSS feed</a>'
          expect(last_response.body).to include(expected_link)
        end

        it "includes a <link> to the podcast RSS" do
          expected_link = '<link rel="alternate" type="application/rss+xml" href="http://example.org/journey-into-space.rss?t=sekrit">'
          expect(last_response.body).to include(expected_link)
        end
      end

      it "404s if you don't use the token" do
        get '/journey-into-space'

        expect(last_response).to be_not_found
      end

      it "404s if you use a non-existent podcast name" do
        allow(PodcastRepository).to receive(:find_podcast_summary).with(anything) { nil }
        get '/journey-into-brandenburg?t=sekrit'

        expect(last_response).to be_not_found
      end
    end

    describe "/:podcast.rss" do
      let(:feed_builder) { instance_double(FeedBuilder, to_s: '<rss/>') }
      let(:podcast) { instance_double(Podcast, feed_builder: feed_builder, programme: programme) }

      context "successfully fetching the feed" do
        before do
          allow(PodcastRepository).to receive(:find_podcast).with('journey-into-space', 'http://example.org/journey-into-space.rss?t=sekrit', anything) { podcast }
          get '/journey-into-space.rss?t=sekrit'
        end

        it "lets you through with the sekrit token" do
          expect(last_response).to be_ok
        end

        it "returns the feed with the correct MIME type" do
          expect(last_response.content_type).to eq('application/rss+xml')
        end

        context "caching headers" do
          it "sets ETag" do
            expect(last_response['ETag']).to eq(%{W/"#{programme.etag}"})
          end

          it "sets Last-Modified" do
            expect(last_response['Last-Modified']).to eq(episode.time.httpdate)
          end

          it "sets Cache-Control: public" do
            expect(last_response['Cache-Control']).to match(/public, max-age=[0-9]+/)
          end

          it "set Expires to a sensible value" do
            expect(Time.httpdate(last_response['Expires'])).to be > Time.now
          end
        end
      end

      it "404s if you don't use the token" do
        get '/journey-into-space.rss'

        expect(last_response).to be_not_found
      end

      it "404s if you use a non-existent podcast name" do
        allow(PodcastRepository).to receive(:find_podcast).with(anything, anything, anything) { nil }
        get '/journey-into-brandenburg.rss?t=sekrit'

        expect(last_response).to be_not_found
      end

    end
  end
end
