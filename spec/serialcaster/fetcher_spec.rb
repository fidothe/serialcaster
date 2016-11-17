require 'vcr_helper'
require 'serialcaster/fetcher'
require 'digest/sha1'
require 'uri'
require 'rack/utils'

module Serialcaster
  RSpec.describe Fetcher do
    let(:credentials) {
      Aws::Credentials.new(
        'AKIAIRZ46DTTXYJK64XA',
        'cMEDR3Wj9eLk284pAxQn/7AdIs8i/7KjdibINobv'
      )
    }
    let(:min_attrs) { {
      bucket: 'mp-serialcaster-test',
      prefix: 'journey into space'
    } }
    let(:attrs) {
      min_attrs.merge({
        credentials: credentials,
        region: 'us-east-1'
      })
    }
    subject { Fetcher.new(attrs) }

    it "has a bucket name" do
      expect(subject.bucket_name).to eq('mp-serialcaster-test')
    end

    it "has a prefix / folder path" do
      expect(subject.prefix).to eq('journey into space')
    end

    context "S3 credentials" do
      it "can have an S3 credentials object passed in in opts" do
        expect(subject.credentials).to be(credentials)
      end

      it "defaults to nil" do
        expect(Fetcher.new(min_attrs).credentials).to be_nil
      end
    end

    context "S3 region" do
      it "can have an S3 region passed in in opts" do
        expect(subject.region).to eq('us-east-1')
      end

      it "defaults to nil" do
        expect(Fetcher.new(min_attrs).region).to be_nil
      end
    end

    context "fetching from S3", :vcr do
      it "can fetch the programme.json file" do
        programme_sha1 = "0f5a6da5323fceeede583b048482da7b077c93f8"
        actual_digest = Digest::SHA1.hexdigest(subject.metadata_io.read)

        expect(actual_digest).to eq(programme_sha1)
      end

      it "can fetch the file name/length list" do
        expected_file_list = [
          ['Journey Into Space - Operation Luna - Episode 1.m4a', 11],
          ['Journey Into Space - The Red Planet - Episode 2.m4a', 11],
          ['Journey Into Space - Operation Luna - Episode 2.m4a', 11],
          ['Journey Into Space - The Red Planet - Episode 1.m4a', 11],
          ['Journey Into Space - Operation Luna - Episode 10.m4a', 11],
          ['Random spacejunk Episode 1.m4a', 11],
          ['Assorted.mp3', 11]
        ].sort

        expect(subject.file_list.sort).to eq(expected_file_list)
      end
    end

    context "generating a file URL" do
      let(:uri) {
        URI.parse(subject.url_for_file('test'))
      }
      let(:query) {
        Rack::Utils.parse_query(uri.query)
      }

      it "points at the right region and bucket" do
        expect(uri.host).to eq('mp-serialcaster-test.s3.amazonaws.com')
      end

      it "points at the right file" do
        expect(uri.path).to eq('/test')
      end

      it "is signed" do
        expect(query).to have_key('X-Amz-Algorithm')
        expect(query).to have_key('X-Amz-Credential')
      end

      it "expires in a week" do
        expect(query['X-Amz-Expires']).to eq((60*60*24*7).to_s)
      end
    end
  end
end
