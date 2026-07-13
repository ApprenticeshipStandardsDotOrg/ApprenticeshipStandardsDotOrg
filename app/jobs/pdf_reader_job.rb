class PdfReaderJob < ApplicationJob
  queue_as :default

  def perform(import_id:, open_ai_prompt: OpenAIPrompt.default)
    pdf = Imports::Pdf.find(import_id)

    pdf.file.open do |io|
      reader = PDF::Reader.new(io)
      text = reader.pages.map { |page| page.text }.to_s

      response = ChatGptGenerateText.new("#{open_ai_prompt.prompt} #{text}").call

      open_ai_import = OpenAIImport.create(import_id: import_id, response: response)
      NewOpenAIImportAvailableNotifier.with(record: open_ai_import, message: "New post").deliver(pdf.assignee)

      response
    end
  end
end
