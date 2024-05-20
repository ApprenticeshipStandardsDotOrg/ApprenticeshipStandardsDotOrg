require "rails_helper"

RSpec.describe SourceFile, type: :model do
  it "has a valid factory" do
    source_file = build(:source_file)

    expect(source_file).to be_valid
  end

  it "factory does not create an extra source file when saved" do
    source_file = create(:source_file)

    expect(source_file).to be_persisted
    expect(SourceFile.count).to eq 1
  end

  it "saves metadata as JSON when updating the record" do
    source_file = build(:source_file)

    source_file.metadata = "{\"date\":\"03/29/2023\"}"
    source_file.save

    expect(source_file.reload.metadata).to eq({"date" => "03/29/2023"})
  end

  describe ".mising_import" do
    it "returns all non-archived source files which do not have an import" do
      sf1a = create(:source_file, :pending)
      sf1b = create(:source_file, :pending)
      create(:imports_uncategorized, source_file: sf1b)

      sf2a = create(:source_file, :completed)
      sf2b = create(:source_file, :completed)
      create(:imports_uncategorized, source_file: sf2b)

      sf3a = create(:source_file, :needs_support)
      sf3b = create(:source_file, :needs_support)
      create(:imports_uncategorized, source_file: sf3b)

      sf4a = create(:source_file, :needs_human_review)
      sf4b = create(:source_file, :needs_human_review)
      create(:imports_uncategorized, source_file: sf4b)

      create(:source_file, :archived)

      expect(described_class.missing_import).to contain_exactly(sf1a, sf2a, sf3a, sf4a)
    end
  end

  describe "#converted_source_file" do
    it "returns the converted source file (pdf)" do
      word = create(:source_file, :docx)
      pdf = create(:source_file, :pdf, original_source_file: word)

      expect(word.converted_source_file).to eq pdf
    end
  end

  describe ".recently_redacted" do
    it "returns records created the day before by default" do
      travel_to(Time.zone.local(2023, 6, 15)) do
        recent_records = [
          create(:source_file, redacted_at: Time.zone.local(2023, 6, 14)),
          create(:source_file, redacted_at: Time.zone.local(2023, 6, 14, 23, 59, 59))
        ]
        create(:source_file, redacted_at: Time.zone.local(2023, 6, 13, 23, 59, 59))

        expect(described_class.recently_redacted).to match_array recent_records
      end
    end

    it "returns records within the passed start and end time" do
      recent_records = [
        create(:source_file, redacted_at: Time.zone.local(2022, 6, 14)),
        create(:source_file, redacted_at: Time.zone.local(2022, 6, 14, 22, 59, 59))
      ]
      create(:source_file, redacted_at: Time.zone.local(2022, 6, 14, 23, 59, 59))

      start_time = Time.zone.local(2022, 6, 14)
      end_time = Time.zone.local(2022, 6, 14, 23)
      expect(described_class.recently_redacted(start_time: start_time, end_time: end_time)).to match_array recent_records
    end
  end

  describe ".pdf_attachment" do
    it "returns only source file with pdf as attachment" do
      create(:source_file, :docx)
      source_file_with_pdf_attachment = create(:source_file, :pdf)

      expect(described_class.pdf_attachment).to match_array [source_file_with_pdf_attachment]
    end
  end

  describe ".word_attachment" do
    it "includes only source files with doc or docx attachments" do
      _pdf = create(:source_file, :pdf)
      doc = create(:source_file, :doc)
      docx = create(:source_file, :docx)

      expect(described_class.word_attachment).to contain_exactly(doc, docx)
    end
  end

  describe ".not_redacted" do
    it "returns only source file without redacted source file" do
      create(:source_file, :with_redacted_source_file)
      source_file_without_redacted_source_file = create(:source_file, :without_redacted_source_file)

      expect(described_class.not_redacted).to match_array [source_file_without_redacted_source_file]
    end
  end

  describe ".ready_for_redaction" do
    it "returns only private source files without attachment, completed and pdf files" do
      source_file_with_all_conditions = create(:source_file,
        :pdf,
        :without_redacted_source_file,
        :completed)

      _source_file_not_complete = create(:source_file,
        :pdf,
        :without_redacted_source_file,
        :pending)

      _source_file_with_docx_attachment = create(:source_file,
        :docx,
        :without_redacted_source_file,
        :completed)

      _source_file_with_redacted_source_file = create(:source_file,
        :pdf,
        :with_redacted_source_file,
        :completed)

      _source_file_public = create(:source_file,
        :pdf,
        :without_redacted_source_file,
        :completed,
        public_document: true)

      expect(described_class.ready_for_redaction).to match_array [source_file_with_all_conditions]
    end
  end

  describe ".not_archived" do
    it "returns records which don't have an archived status" do
      _archived = create(:source_file, status: "archived")
      pending = create(:source_file, status: "pending")

      expect(described_class.not_archived.pluck(:id)).to eql([pending.id])
    end
  end

  describe ".already_redacted" do
    it "returns only source files that are already redacted" do
      source_file_with_redacted_source_file = create(:source_file, :with_redacted_source_file)
      create(:source_file, :without_redacted_source_file)

      expect(described_class.already_redacted).to match_array [source_file_with_redacted_source_file]
    end
  end

  describe "#convert_doc_file_to_pdf" do
    it "calls DocToPdfConverter job if can be converted" do
      allow_any_instance_of(SourceFile).to receive(:can_be_converted_to_pdf?).and_return(true)
      expect(DocToPdfConverterJob).to receive(:perform_later)

      create(:source_file, :docx)
    end

    it "does not call DocToPdfConverter job on create if does not have conditions to convert" do
      allow_any_instance_of(SourceFile).to receive(:can_be_converted_to_pdf?).and_return(false)
      expect(DocToPdfConverterJob).to_not receive(:perform_later)

      create(:source_file, :pdf)
    end

    it "does not call DocToPdfConverter job if source file is persisted" do
      source_file = create(:source_file, :docx)

      expect(DocToPdfConverterJob).to_not receive(:perform_later)

      source_file.courtesy_notification_completed!
    end
  end

  describe "#associated_occupation_standards" do
    it "returns unique occupation standards" do
      source_file = create(:source_file)
      data_import = create(:data_import, source_file: source_file)
      occupation_standard = data_import.occupation_standard
      create(:data_import, source_file: source_file, occupation_standard: occupation_standard)

      expect(source_file.associated_occupation_standards).to eq [occupation_standard]
    end
  end

  describe "#needs_courtesy_notification?" do
    it "is false if status is pending" do
      source_file = build(:source_file, :pending)

      expect(source_file.needs_courtesy_notification?).to be false
    end

    it "is false if status is needs_support" do
      source_file = build(:source_file, :needs_support)

      expect(source_file.needs_courtesy_notification?).to be false
    end

    it "is false if status is completed and courtesy_notification is completed" do
      source_file = build(:source_file, :completed, courtesy_notification: :completed)

      expect(source_file.needs_courtesy_notification?).to be false
    end

    it "is false if status is completed and courtesy_notification is not_required" do
      source_file = build(:source_file, :completed, courtesy_notification: :not_required)

      expect(source_file.needs_courtesy_notification?).to be false
    end

    it "is true if status is completed and courtesy_notification is pending" do
      source_file = build(:source_file, :completed, courtesy_notification: :pending)

      expect(source_file.needs_courtesy_notification?).to be true
    end
  end

  describe "#organization" do
    it "returns organization from standards_import association" do
      perform_enqueued_jobs do
        create(:standards_import, :with_files, organization: "Pipe Fitters R Us")
        source_file = SourceFile.last

        expect(source_file.organization).to eq "Pipe Fitters R Us"
      end
    end
  end

  describe "#notes" do
    it "returns notes from standards_import association" do
      perform_enqueued_jobs do
        create(:standards_import, :with_files, notes: "From scraper job")
        source_file = SourceFile.last

        expect(source_file.notes).to eq "From scraper job"
      end
    end
  end

  describe "#claimed?" do
    it "returns true if there is an assignee" do
      admin = build_stubbed(:admin)
      source_file = build_stubbed(:source_file, assignee: admin)

      expect(source_file).to be_claimed
    end

    it "returns false if there is no assignee" do
      source_file = build_stubbed(:source_file, assignee: nil)

      expect(source_file).to_not be_claimed
    end
  end

  describe "#pdf?" do
    it "returns true when attachment is a pdf file" do
      source_file = create(:source_file, :pdf)

      expect(source_file.pdf?).to be(true)
    end

    it "returns false when attachment is docx" do
      source_file = create(:source_file, :docx)

      expect(source_file.pdf?).to be(false)
    end
  end

  describe "#docx?" do
    it "returns true when attachment is a docx file" do
      source_file = create(:source_file, :docx)

      expect(source_file.docx?).to be(true)
    end

    it "returns false when attachment is not docx" do
      source_file = create(:source_file, :doc)

      expect(source_file.docx?).to be(false)
    end
  end

  describe "#word?" do
    it "is true if the content_type is docx" do
      source_file = create(:source_file, :docx)

      expect(source_file).to be_word
    end

    it "is true if the content_type is doc" do
      source_file = create(:source_file, :doc)

      expect(source_file).to be_word
    end

    it "is false if the content_type is not doc or docx" do
      source_file = create(:source_file, :pdf)

      expect(source_file).to_not be_word
    end
  end

  describe "#redacted_source_file_url" do
    it "returns nil if file not present" do
      source_file = build(:source_file, redacted_source_file: nil)

      expect(source_file.redacted_source_file_url).to be nil
    end

    it "returns file url if file present", :url_generation do
      source_file = build(:source_file, redacted_source_file: fixture_file_upload("pixel1x1.jpg", "image/jpeg"))

      expect(source_file.redacted_source_file_url).to be_present
    end
  end

  describe "#file_for_redaction" do
    it "returns redacted_source_file if present" do
      source_file = build(:source_file, redacted_source_file: fixture_file_upload("pixel1x1.jpg", "image/jpeg"))

      expect(source_file.file_for_redaction).to eq source_file.redacted_source_file
    end

    it "returns active_storage_attachment if redacted_source_file is not present" do
      source_file = create(:source_file, redacted_source_file: nil)

      expect(source_file.file_for_redaction).to eq source_file.active_storage_attachment
    end
  end

  describe "#can_be_converted_to_pdf?" do
    it "is true if docx file, not bulletin, and not archived" do
      source_file = build(:source_file, :docx)

      expect(source_file.can_be_converted_to_pdf?).to be_truthy
    end

    it "is true if doc file, not bulletin, and not archived" do
      source_file = build(:source_file, :doc)

      expect(source_file.can_be_converted_to_pdf?).to be_truthy
    end

    it "is false if not word file" do
      source_file = build(:source_file, :pdf)

      expect(source_file.can_be_converted_to_pdf?).to be_falsey
    end

    it "is false if word file but is marked as a bulletin" do
      source_file = build(:source_file, :docx, bulletin: true)

      expect(source_file.can_be_converted_to_pdf?).to be_falsey
    end

    it "is false if word file, not a bulletin, but archived" do
      source_file = build(:source_file, :docx, :archived)

      expect(source_file.can_be_converted_to_pdf?).to be_falsey
    end
  end

  describe "#create_import!" do
    context "when import already exists" do
      it "does not create import record" do
        source_file = create(:source_file, :pending)
        create(:imports_uncategorized, source_file: source_file)

        resp = nil
        expect {
          resp = source_file.create_import!
        }.to_not change(Import, :count)
        expect(resp).to be_nil
      end
    end

    context "when import does not already exist" do
      it "when archived, it does not create Uncategorized::Import record" do
        source_file = create(:source_file, :archived)

        resp = nil
        expect {
          resp = source_file.create_import!
        }.to_not change(Import, :count)
        expect(resp).to be_nil
      end

      it "when not archived, creates Uncategorized::Import record" do
        metadata = {"foo" => "bar"}
        source_file = create(:source_file, :pending, public_document: true, metadata: metadata)

        import = nil
        expect {
          import = source_file.create_import!
        }.to change(Imports::Uncategorized, :count).by(1)
          .and change(ActiveStorage::Attachment, :count).by(1)
          .and change(ActiveStorage::Blob, :count).by(0)

        expect(import).to be_a(Imports::Uncategorized)
        expect(import.source_file).to eq source_file
        expect(import.parent).to eq source_file.standards_import
        expect(import.filename.to_s).to eq source_file.filename.to_s
        expect(import).to be_public_document
        expect(import.metadata).to eq metadata
        expect(import).to be_unfurled
      end
    end
  end
end
