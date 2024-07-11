class PdfArchiveEvaluator
  def initialize(pdf)
    @pdf = pdf
  end

  def call
    return unless @pdf.filename.include?("oleObject") || @pdf.filename.include?("ActiveStorage")
    return if @pdf.filename.eql? "oleObject2.pdf"
    return if contains_appendix_a.eql? "true"

    result = match_criteria
    return unless result.eql? "true"

    @pdf.update(status: :archived)
  end

  private

  def archive_criteria
    ["requirements for apprenticeship sponsors reference guide",
      "apprentice agreement and registration",
      "employer acceptance agreement",
      "appendix c",
      "appendix d"]
  end

  def match_criteria
    prompt = "Does the following content contain any of these titles, #{archive_criteria}? Capitalization does not matter. Return 'true' or 'false'. Content: #{extract_pdf_content}"
    gpt = ChatGptGenerateText.new(prompt)
    gpt.call
  end

  def contains_appendix_a
    prompt = "Does the following content contain an Appendix A? Capitalization does not matter. Return 'true' or 'false'. Content: #{extract_pdf_content}"
    gpt = ChatGptGenerateText.new(prompt)
    gpt.call
  end

  def extract_pdf_content
    PDF::Reader.new(StringIO.new(@pdf.file.download)).pages.map(&:text).join("").tr("\n", " ").squeeze(" ").downcase
  end
end
