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

    let(:jis_summary) {
      ProgrammeSummary.new({
        title: "Journey into space",
        description: "Classic"
      })
    }
    let(:jis_fetcher) {
      instance_double(Fetcher)
    }
    let(:jis_podcast) {
      instance_double(Podcast, programme_summary: jis_summary)
    }

    before do
      allow(App).to receive(:podcasts) { {
        'journey-into-space' => jis_podcast
      } }
    end

    describe "/" do
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
      it "lets you through with the sekrit token" do
        get '/journey-into-space?t=sekrit'

        expect(last_response).to be_ok
      end

      it "404s if you don't use the token" do
        get '/journey-into-space'

        expect(last_response).to be_not_found
      end

      it "404s if you use a non-existent podcast name" do
        get '/journey-into-brandenburg?t=sekrit'

        expect(last_response).to be_not_found
      end

      it "shows a standard HTML link to the podcast RSS" do
        get '/journey-into-space?t=sekrit'

        expected_link = '<a href="http://example.org/journey-into-space.rss?t=sekrit">Podcast RSS feed</a>'
        expect(last_response.body).to include(expected_link)
      end

      it "includes a <link> to the podcast RSS" do
        get '/journey-into-space?t=sekrit'

        expected_link = '<link rel="alternate" type="application/rss+xml" href="http://example.org/journey-into-space.rss?t=sekrit">'
        expect(last_response.body).to include(expected_link)
      end
    end

    describe "/:podcast.rss" do
      let(:feed_builder) { instance_double(FeedBuilder, to_s: '<rss/>') }

      before do
        allow(jis_podcast).to receive(:feed_builder).with("http://example.org/journey-into-space.rss?t=sekrit", anything) { feed_builder }
      end

      it "lets you through with the sekrit token" do
        get '/journey-into-space.rss?t=sekrit'

        expect(last_response).to be_ok
      end

      it "404s if you don't use the token" do
        get '/journey-into-space.rss'

        expect(last_response).to be_not_found
      end

      it "404s if you use a non-existent podcast name" do
        get '/journey-into-brandenburg.rss?t=sekrit'

        expect(last_response).to be_not_found
      end

      it "returns the feed with the correct MIME type" do
        get '/journey-into-space.rss?t=sekrit'

        expect(last_response.content_type).to eq('application/rss+xml')
      end
    end
  end
end
