class PdfArchiveEvaluatorJob < ApplicationJob
  queue_as :default

  def perform
    Imports::Pdf.pending.each do |pdf|
      next unless pdf.filename.include?("oleObject") || pdf.filename.include?("ActiveStorage")
      next unless pdf.filename.include?("oleObject4.pdf")

      next if contains_appendix_a?(pdf)

      sleep 2
      next unless match_criteria?(pdf)

      pdf.update(status: :archived)
      sleep 2
    end
  end

  private

  def archive_criteria
    ["requirements for apprenticeship sponsors reference guide",
      "apprentice agreement and registration",
      "employer acceptance agreement",
      "appendix c",
      "appendix d"]
  end

  def match_criteria?(pdf)
    prompt = "Does the following content contain any of these titles, #{archive_criteria}? Capitalization does not matter. Return 'true' or 'false'. Content: #{extract_pdf_content(pdf)}"
    gpt = ChatGptGenerateText.new(prompt)
    resp = gpt.call.downcase
    puts "MATCH CRITERIA?? #{resp}"
    resp == "true"
  end

  def contains_appendix_a?(pdf)
    prompt = "Does the following content contain a dedicated Appendix A page? References to an Appendix A do not count. Capitalization does not matter. Return 'true' or 'false'. Content: #{extract_pdf_content(pdf)}"
    gpt = ChatGptGenerateText.new(prompt)
    resp = gpt.call.downcase
    puts "CONTAINS APPENDIX A? #{resp}"
    resp == "true"
  end

  def extract_pdf_content(pdf)
    PDF::Reader.new(StringIO.new(pdf.file.download)).pages.map(&:text).join("").tr("\n", " ").squeeze(" ").downcase
  end
end
