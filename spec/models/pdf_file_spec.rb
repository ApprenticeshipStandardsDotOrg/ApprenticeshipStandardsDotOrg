require "rails_helper"

RSpec.describe PdfFile, type: :model do
  describe 'object' do
    it 'can return underlying PDF::File object' do
      expect(described_object.pdf_reader).to be_a(PDF::Reader)
    end

    it 'returns expected text' do
      content = "6th period    31-36 months 4501-5400 OJT"
      expect(described_object.text).to match(/#{content}/)
      expect(described_object.text.length).to be > 7000
    end

    it 'still allows other methods of PDF::Reader' do
      expect(described_object.page_count).to eq 3
    end

    def described_object
      described_class.new(PDF::Reader.new(file_fixture("process_data_example_01.pdf")))
    end
  end

  describe '.text class method' do
    it 'returns expected text' do
      file = file_fixture("process_data_example_01.pdf")
      content = "6th period    31-36 months 4501-5400 OJT"

      expect(described_class.text(file)).to match(/#{content}/)
      expect(described_class.text(file).length).to be > 7000
    end
  end
end
