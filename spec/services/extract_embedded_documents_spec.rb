require "rails_helper"

RSpec.describe ExtractEmbeddedDocuments do
  around do |example|
    Dir.mktmpdir do |directory|
      @directory = directory
      example.run
    end
  end

  def fixture(name)
    Rails.root.join("spec/fixtures/files", name)
  end

  def extract(path)
    described_class.call(path, directory: File.join(@directory, "output"))
  end

  def ole_with_object
    path = File.join(@directory, "wrapper.doc")
    Ole::Storage.open(path, "w") do |ole|
      ole.dir.mkdir("ObjectPool")
      ole.dir.mkdir("ObjectPool/object1")
      yield ole
    end
    path
  end

  it "reconstructs a Word document from a binary DOC ObjectPool" do
    path = ole_with_object do |ole|
      Ole::Storage.open(fixture("document.doc").to_s, "r") do |source|
        source.root.children.each do |child|
          copy = Ole::Storage::Dirent.new(ole, type: child.type)
          ole.dirent_from_path("ObjectPool/object1") << copy
          Ole::Storage::Dirent.copy(child, copy)
        end
      end
    end

    result = extract(Pathname.new(path))

    expect(result.unsupported).to be_empty
    expect(result.paths.size).to eq 1
    Ole::Storage.open(fixture("document.doc").to_s, "r") do |source|
      Ole::Storage.open(result.paths.first, "r") do |recovered|
        expect(recovered.file.read("WordDocument")).to eq source.file.read("WordDocument")
        expect(recovered.file.read("1Table")).to eq source.file.read("1Table")
      end
    end
  end

  it "recovers an OOXML Word document stored in an OLE Package stream" do
    bytes = File.binread(fixture("document.docx"))
    path = ole_with_object { |ole| ole.file.open("ObjectPool/object1/Package", "w") { |io| io.write(bytes) } }

    result = extract(path)

    expect(result.paths.first).to end_with(".docx")
    expect(File.binread(result.paths.first)).to eq bytes
  end

  it "extracts DOCX listing Word and PDF payloads without treating OLE wrappers as PDFs" do
    result = extract(fixture("docx_file_attachments.docx"))

    expect(result.unsupported).to be_empty
    expect(result.paths.size).to eq 7
    expect(result.paths.count { |path| path.end_with?(".pdf") }).to eq 5
    result.paths.grep(/\.pdf$/).each { |path| expect(File.binread(path, 5)).to eq "%PDF-" }
  end

  it "reports unsupported objects rather than silently dropping them" do
    path = ole_with_object { |ole| ole.file.open("ObjectPool/object1/Unknown", "w") { |io| io.write("bytes") } }

    result = extract(path)

    expect(result.paths).to be_empty
    expect(result.unsupported.join).to include "Unknown"
  end

  it "returns no attachments for an ordinary Word document" do
    expect(extract(fixture("document.doc")).paths).to be_empty
    expect(extract(fixture("document.docx")).paths).to be_empty
  end

  it "unwraps binary PDF payloads from Ole10Native and ignores wrapper labels" do
    bytes = File.binread(fixture("pixel1x1.pdf"))
    native = [0, 2].pack("Vv") + "file.pdf\0original.pdf\0" + [0, 3, 5].pack("vvV") + "temp\0" + [bytes.bytesize].pack("V") + bytes
    path = ole_with_object { |ole| ole.file.open("ObjectPool/object1/\x01Ole10Native", "w") { |io| io.write(native) } }

    result = extract(path)

    expect(result.unsupported).to be_empty
    expect(File.binread(result.paths.first)).to eq bytes
  end

  it "rejects truncated native objects instead of guessing their contents" do
    path = ole_with_object { |ole| ole.file.open("ObjectPool/object1/\x01Ole10Native", "w") { |io| io.write("broken") } }

    expect { extract(path) }.to raise_error(ArgumentError, /Truncated native/)
  end

  it "leaves inline WordPerfect graphics to the Word renderer" do
    path = ole_with_object { |ole| ole.file.open("ObjectPool/object1/\x03WPG20", "w") { |io| io.write("graphic") } }

    result = extract(path)

    expect(result.paths).to be_empty
    expect(result.unsupported).to be_empty
  end
end
