class ArchiveOleObjectPdfs
  def initialize(pdf)
    # @pdfs = Imports::Pdf.ole_object
    @pdf = pdf
  end

  def call
    return unless @pdf.filename.include?('oleObject')
    return if @pdf.filename.eql? 'oleObject2.pdf'

    puts @pdf.filename
    chatgpt_match_criteria
  end

  # private

  def archive_criteria
    ['requirements for apprenticeship sponsors reference guide', 'apprenticeship agreement and registration']
  end

  def chatgpt_match_criteria
    content = extract_pdf_content
    prompt = "Does the following content contain any of these titles, #{archive_criteria}? Capitalization does not matter. Return a boolean. Content: #{content}"
    gpt = ChatGptGenerateText.new(prompt)
    gpt.call
  end

  def extract_pdf_content
    PDF::Reader.new(StringIO.new(@pdf.file.download)).pages.map(&:text).join('').gsub(/\n/, ' ').squeeze(' ').downcase
  end
end
