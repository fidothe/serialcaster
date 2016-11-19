require 'serialcaster/programme_summary'

module Serialcaster
  RSpec.describe ProgrammeSummary do
    let(:attrs) { {
      title: 'Journey Into Space',
      description: 'Classic BBC radio drama',
    } }
    subject {
      ProgrammeSummary.new(attrs)
    }

    it "has a title" do
      expect(subject.title).to eq('Journey Into Space')
    end

    it "has a description" do
      expect(subject.description).to eq('Classic BBC radio drama')
    end

    context "equality" do
      it "compares equal when all attributes match" do
        expect(subject).to eq(ProgrammeSummary.new(attrs))
      end

      it "compares non-equal when one attribute doesn't match" do
        expect(subject).not_to eq(ProgrammeSummary.new(attrs.merge(title: 'Boo')))
      end
    end
  end
end
