class PdfReaderJob < ApplicationJob
  queue_as :default

  BASE_PROMPT = "Get the Occupation standard info from the following text in JSON format. JSON output needs the following fields:\
      title: Title of the occupation standard.
      existingTitle: An existing or alternative title for the occupation.
      onetCode: Also can be found as O*NET code.
      rapidsCode: RAPIDS code for the occupation.
      organization: The name of the organization.
      registrationAgency: The name of the agency of the state.
      ojtType: On the job type or apprenticeship approach. It must be one of the following values:
      \"time\", \"competency\", or \"hybrid\". Transform if needed to match any of those three values. An
      example of an expected transformation is from \"Competency-based\" to \"competency\".
      registrationDate: The registration date of the occupation.
      workProcesses: an array of work processes. Each work process has the following fields:
      title: title of the work process.
      defaultHours: amount of hours. It is optional. If value not found, return null.
      minimumHours: the minimum amount of hours required. If value not found, return null.
      maximumHours: the maximum amount of hours required. If value not found, return null.
      competencies: It is an array of text with each competency representing a line.
      Each competency has the following fields:
      title: title of the competency.
      relatedInstructions: A new array of related instructions. Related instructions are not part of competencies or work processes. Each related instruction has the following fields:
      title: Title of the related instruction.
      description: Description of the related instruction. This field is optional.
      hours: Total amount of hours. This field is optional.

      Return only the output in JSON format without any block, code or markdown.

      The input text is:\n\n
  "

  def perform(import_id)
    pdf = Imports::Pdf.find(import_id)

    pdf.file.open do |io|
      reader = PDF::Reader.new(io)
      text = reader.pages.map { |page| page.text }.to_s

      ChatGptGenerateText.new("#{BASE_PROMPT} #{text}").call
    end
  end
end
