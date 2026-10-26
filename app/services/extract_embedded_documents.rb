require "ole/storage"

# Extracts document payloads, not the preview images rendered by LibreOffice.
# The caller owns the output directory and its cleanup.
class ExtractEmbeddedDocuments
  Result = Data.define(:paths, :unsupported)
  OLE_SIGNATURE = "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1".b.freeze

  def self.call(path, directory:)
    new(directory).call(path)
  end

  def initialize(directory)
    @directory = directory
    @paths = []
    @unsupported = []
  end

  def call(path)
    FileUtils.mkdir_p(@directory)
    signature = File.binread(path, 8)
    if signature == OLE_SIGNATURE
      Ole::Storage.open(path.to_s, "r") do |ole|
        pool = ole.root.children.find { |entry| entry.name == "ObjectPool" }
        pool&.children&.each { |entry| extract_ole_object(entry) if entry.dir? }
      end
    elsif signature.start_with?("PK")
      Zip::File.open(path) do |zip|
        zip.each do |entry|
          next if entry.directory? || !entry.name.start_with?("word/embeddings/")

          bytes = entry.get_input_stream.read
          if bytes.start_with?(OLE_SIGNATURE)
            Ole::Storage.open(StringIO.new(bytes)) { |ole| extract_ole_object(ole.root) }
          elsif bytes.start_with?("%PDF-")
            save(bytes, ".pdf")
          elsif bytes.start_with?("PK") && entry.name.end_with?(".docx")
            save(bytes, ".docx")
          else
            @unsupported << entry.name
          end
        end
      end
    end
    Result.new(paths: @paths, unsupported: @unsupported)
  end

  private

  def extract_ole_object(entry)
    names = entry.children.map(&:name)
    # WordPerfect graphics are rendered in place by LibreOffice, rather than
    # being independent document attachments.
    return if names.include?("\x03WPG20")

    if names.include?("WordDocument") || names.include?("Workbook")
      path = next_path(names.include?("WordDocument") ? ".doc" : ".xls")
      Ole::Storage.open(path, "w") do |output|
        entry.children.each do |child|
          copy = Ole::Storage::Dirent.new(output, type: child.type)
          output.root << copy
          Ole::Storage::Dirent.copy(child, copy)
        end
      end
      @paths << path
    elsif (payload = entry.children.find { |child| ["CONTENTS", "Package", "\x01Ole10Native"].include?(child.name) })
      bytes = payload.read
      bytes = native_payload(bytes) if payload.name == "\x01Ole10Native"
      if bytes.start_with?("%PDF-")
        save(bytes, ".pdf")
      elsif bytes.start_with?("PK") && word_package?(bytes)
        save(bytes, ".docx")
      else
        @unsupported << "#{entry.name}/#{payload.name} (unknown document format)"
      end
    else
      @unsupported << "#{entry.name}: #{names.join(", ")}"
    end
  end

  # Ole10Native wraps packaged files in a binary header and null-terminated
  # labels/paths. Use the declared payload size, never search for a PDF marker.
  def native_payload(bytes)
    io = StringIO.new(bytes)
    io.read(6)
    2.times { raise ArgumentError, "Truncated native object" unless io.gets("\0")&.end_with?("\0") }
    raise ArgumentError, "Truncated native flags" unless io.read(4)&.bytesize == 4

    path_size = read_size(io)
    raise ArgumentError, "Truncated native path" unless io.read(path_size)&.bytesize == path_size

    size = read_size(io)
    payload = io.read(size)
    raise ArgumentError, "Truncated native payload" unless payload&.bytesize == size

    payload
  end

  def read_size(io)
    bytes = io.read(4)
    raise ArgumentError, "Truncated native size" unless bytes&.bytesize == 4

    bytes.unpack1("V")
  end

  def word_package?(bytes)
    Zip::File.open_buffer(StringIO.new(bytes)) { |zip| zip.find_entry("word/document.xml").present? }
  end

  def save(bytes, extension)
    path = next_path(extension)
    File.binwrite(path, bytes)
    @paths << path
  end

  def next_path(extension)
    File.join(@directory, "embedded-#{@paths.length + 1}#{extension}")
  end
end
