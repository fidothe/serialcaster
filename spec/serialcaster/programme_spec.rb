require 'serialcaster/programme'

module Serialcaster
  RSpec.describe Programme do
    let(:schedule) { double("Serialcaster::Schedule") }
    let(:episode) { double("Serialcaster::Episode") }
    let(:episodes) { [episode] }
    let(:attrs) { {
      title: 'Journey Into Space',
      description: 'Classic BBC radio drama',
      schedule: schedule,
      episodes: episodes
    } }
    subject {
      Programme.new(attrs)
    }

    it "has a title" do
      expect(subject.title).to eq('Journey Into Space')
    end

    it "has a description" do
      expect(subject.description).to eq('Classic BBC radio drama')
    end

    it "has a schedule" do
      expect(subject.schedule).to eq(schedule)
    end

    it "has an episode list" do
      expect(subject.episodes).to eq(episodes)
    end

    context "equality" do
      it "compares equal when all attributes match" do
        expect(subject).to eq(Programme.new(attrs))
      end

      it "compares non-equal when one attribute doesn't match" do
        expect(subject).not_to eq(Programme.new(attrs.merge(title: 'Boo')))
      end
    end
  end
end
