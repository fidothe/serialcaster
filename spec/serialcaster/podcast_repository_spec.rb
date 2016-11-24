require 'serialcaster/podcast_repository'

module Serialcaster
  RSpec.describe PodcastRepository do
    let(:prefix) { 'journey-into-space' }
    let(:metadata_io) { double }
    let(:file_list) { double }
    let(:fetcher) {
      instance_double(Fetcher, {
        metadata_io: metadata_io, file_list: file_list
      })
    }
    let(:creator) {
      instance_double(Creator)
    }

    subject { PodcastRepository.new('bukkit') }

    it "knows what bucket to use" do
      expect(subject.bucket_name).to eq('bukkit')
    end

    it "can fetch all possible podcast prefixes" do
      allow(Fetcher).to receive(:list).with('bukkit') { ['programme'] }

      expect(subject.all_prefixes).to eq(['programme'])
    end

    context "validating prefixes" do
      before do
        allow(subject).to receive(:all) { {'programme' => double} }
      end

      it "reports that a good prefix is valid" do
        expect(subject.exists?('programme')).to be(true)
      end

      it "reports that a bad prefix is not valid" do
        expect(subject.exists?('other')).to be(false)
      end
    end

    context "finding and creating PodcastBuilders" do
      let(:podcast_builder) { instance_double(PodcastBuilder) }

      context "finding/creating the Builder" do
        it "creates and provides access to a builder instance for a prefix" do
          allow(subject).to receive(:all_prefixes) { ['prefix'] }

          expect(Fetcher).to receive(:new).with({
            bucket: 'bukkit', prefix: 'prefix'
          }) { fetcher }
          expect(Creator).to receive(:new).with(metadata_io, file_list) {
            creator
          }
          expect(PodcastBuilder).to receive(:new).with({
            prefix: 'prefix', fetcher: fetcher, creator: creator
          }) { podcast_builder }

          expect(subject.find('prefix')).to eq(podcast_builder)
        end
      end
    end

    context "convenience finders for the Podcast and PodcastSummary instances" do
      let(:url) { 'http://a.url/' }
      let(:time) { Time.now }

      it "finds and inflates a podcast correctly" do
        builder = instance_double(PodcastBuilder)
        podcast = double

        expect(subject).to receive(:find).with('prefix') { builder }
        expect(builder).to receive(:podcast).with(url, time) { podcast }

        actual = subject.find_podcast('prefix', url, time)

        expect(actual).to be(podcast)
      end

      it "finds and inflates a podcast summary correctly" do
        builder = instance_double(PodcastBuilder)
        summary = double

        expect(subject).to receive(:find).with('prefix') { builder }
        expect(builder).to receive(:podcast_summary) { summary }

        actual = subject.find_podcast_summary('prefix')

        expect(actual).to be(summary)
      end

      it "can return all possible podcast summaries" do
        summary = double
        builder = instance_double(PodcastBuilder, podcast_summary: summary)
          allow(subject).to receive(:all_prefixes) { ['prefix'] }

        expect(subject).to receive(:create).with('prefix') { builder }

        expect(subject.podcast_summaries).to eq([summary])
      end
    end

    context "convenience class-level functions" do
      before do
        if PodcastRepository.instance_variable_defined?(:@instance)
          PodcastRepository.send(:remove_instance_variable, :@instance)
        end
      end

      it "creates an instance using the bucket name ENV var" do
        ENV['SERIALCASTER_BUCKET'] = 'mp-serialcaster-test'
        instance = double
        expect(PodcastRepository).to receive(:new).with('mp-serialcaster-test') {
          instance
        }

        expect(PodcastRepository.send(:instance)).to be(instance)
      end

      it "memoizes the instance" do
        first = PodcastRepository.send(:instance)
        second = PodcastRepository.send(:instance)

        expect(first).to be(second)
      end

      it "exposes find_podcast on the instance" do
        instance = PodcastRepository.send(:instance)
        prefix, url, time = 'prefix', 'http://a.url', Time.now
        result = double

        expect(instance).to receive(:find_podcast).with(prefix, url, time) {
          result
        }

        expect(PodcastRepository.find_podcast(prefix, url, time)).to be(result)
      end

      it "exposes find_podcast_summary on the instance" do
        instance = PodcastRepository.send(:instance)
        prefix = 'prefix'
        result = double

        expect(instance).to receive(:find_podcast_summary).with(prefix) {
          result
        }

        expect(PodcastRepository.find_podcast_summary(prefix)).to be(result)
      end

      it "exposes all_podcast_summaries on the instance" do
        instance = PodcastRepository.send(:instance)
        result = double

        expect(instance).to receive(:podcast_summaries) {
          result
        }

        expect(PodcastRepository.podcast_summaries).to be(result)
      end
    end
  end
end
